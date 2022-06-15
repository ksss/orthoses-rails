stdlib_dependencies = %w[benchmark date digest json logger monitor mutex_m pathname singleton time]
gem_dependencies = %w[nokogiri]
rails_dependencies = %w[]

VERSIONS.each do |version|
  namespace version do
    namespace :active_support do
      export = "export/activesupport/#{version}"

      desc "export to #{export}"
      task :export do
        sh "rm -fr #{export}"
        sh "mkdir -p #{export}"

        # minimum
        sh "cp -a out/#{version}/active_support.rbs #{export}"
        sh "cp -a out/#{version}/active_support #{export}"
        sh "rm #{export}/active_support/railtie.rbs"

        # core_ext
        %w[
          array benchmark big_decimal class date date_and_time date_time digest
          enumerable file hash integer kernel load_error marshal module name_error numeric
          object pathname range regexp securerandom string symbol time uri
        ].each do |lib|
          out = "out/#{version}/#{lib}"
          sh "cp -a #{out} #{export}" if File.exist?(out)
          sh "cp -a #{out}.rbs #{export}" if File.exist?("#{out}.rbs")
        end

        Pathname(export).join("EXTERNAL_TODO.rbs").write(<<~RBS)
          module Minitest
            class Test
              def name: () -> untyped
              def assert_raises: () -> untyped
              def refute_empty: () -> untyped
              def refute_equal: () -> untyped
              def refute_in_delta: () -> untyped
              def refute_in_epsilon: () -> untyped
              def refute_includes: () -> untyped
              def refute_instance_of: () -> untyped
              def refute_kind_of: () -> untyped
              def refute_match: () -> untyped
              def refute_nil: () -> untyped
              def refute_operator: () -> untyped
              def refute_predicate: () -> untyped
              def refute_respond_to: () -> untyped
              def refute_same: () -> untyped
            end
          end
          module DRb
            module DRbUndumped
            end
          end
          module Concurrent
            class Map
            end
          end
        RBS

        case version
        when "6.0", "6.1"
          sh "rm -fr #{export}/uri"
        when "7.0"
          # deprecated
          sh "rm -fr #{export}/uri{,.rbs}"
        end

        generate_test_script(
          gem: :activesupport,
          version: version,
          export: export,
          stdlib_dependencies: stdlib_dependencies,
          gem_dependencies: gem_dependencies,
          rails_dependencies: rails_dependencies,
        )

        Pathname(export).join('_test').join('test.rb').write(<<~'RUBY')
          require 'active_support/all'

          # Test ActiveSupport::NumericWithFormat
          42.to_s
          42.to_s(:phone)
        RUBY
      end

      desc "validate version=#{version} gem=active_support"
      task :validate do
        stdlib_opt = stdlib_dependencies.map{"-r #{_1}"}.join(" ")
        gem_opt = gem_dependencies.map{"-I ../../.gem_rbs_collection/#{_1}"}.join(" ")
        rails_opt = rails_dependencies.map{"-I export/#{_1}/#{version}"}.join(" ")
        sh "rbs #{stdlib_opt} #{gem_opt} #{rails_opt} -I #{export} validate --silent"
      end
    end
  end
end
