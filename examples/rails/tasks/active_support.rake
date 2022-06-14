namespace :export do
  namespace :active_support do
    task all: VERSIONS

    stdlib_dependencies = %w[benchmark date digest json logger monitor mutex_m pathname singleton time]
    gem_dependencies = %w[nokogiri]
    rails_dependencies = %w[]

    VERSIONS.each do |version|
      task version do |t|
        export = "export/activesupport/#{version}"

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

        Pathname(export).join('_scripts').tap(&:mkdir).join('test').write(<<~RUBY)
          #!/usr/bin/env bash

          # set -eou => Exit command with non-zero status code, Output logs of every command executed, Treat unset variables as an error when substituting.
          set -eou pipefail
          # Internal Field Separator - Linux shell variable
          IFS=$'\n\t'
          # Print shell input lines
          set -v

          # Set RBS_DIR variable to change directory to execute type checks using `steep check`
          RBS_DIR=$(cd $(dirname $0)/..; pwd)
          # Set REPO_DIR variable to validate RBS files added to the corresponding folder
          REPO_DIR=$(cd $(dirname $0)/../../..; pwd)
          # Validate RBS files, using the bundler environment present
          bundle exec rbs --repo=$REPO_DIR #{stdlib_dependencies.map{"-r #{_1}"}.join(" ")} \\
            #{gem_dependencies.map{"-r #{_1}"}.join(" ")} \\
            -r activesupport validate --silent

          cd ${RBS_DIR}/_test
          # Run type checks
          bundle exec steep check
        RUBY
        sh "chmod +x #{Pathname(export).join('_scripts').join('test')}"
        Pathname(export).join('_test').tap(&:mkdir).join('Steepfile').write(<<~RUBY)
          D = Steep::Diagnostic

          target :test do
            signature "."
            check "."

            repo_path "../../../"

          #{stdlib_dependencies.map{"  library \"#{_1}\""}.join("\n")}
          #{gem_dependencies.map{"  library \"#{_1}\""}.join("\n")}

            library "activesupport:#{version}"

            configure_code_diagnostics(D::Ruby.all_error)
          end
        RUBY
        Pathname(export).join('_test').join('test.rb').write(<<~'RUBY')
          require 'active_support/all'

          # Test ActiveSupport::NumericWithFormat
          42.to_s
          42.to_s(:phone)
        RUBY

        stdlib_opt = stdlib_dependencies.map{"-r #{_1}"}.join(" ")
        gem_opt = gem_dependencies.map{"-I ../../.gem_rbs_collection/#{_1}"}.join(" ")
        rails_opt = rails_dependencies.map{"-I export/#{_1}/#{version}"}.join(" ")
        sh "rbs #{stdlib_opt} #{gem_opt} #{rails_opt} -I #{export} validate --silent"
      end
    end
  end
end
