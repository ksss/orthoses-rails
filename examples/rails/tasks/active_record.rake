stdlib_dependencies = %w[time monitor singleton logger mutex_m json date benchmark digest forwardable did_you_mean openssl socket]
gem_dependencies = %w[nokogiri]
rails_dependencies = %w[activesupport activemodel activejob]

VERSIONS.each do |version|
  namespace version do
    namespace :active_record do
      export = "export/activerecord/#{version}"

      desc "export to #{export}"
      task :export do
        sh "rm -fr #{export}"
        sh "mkdir -p #{export}"

        sh "cp -a out/#{version}/active_record.rbs #{export}"
        sh "cp -a out/#{version}/active_record #{export}"
        sh "cp -a out/#{version}/arel #{export}"
        sh "cp -a out/#{version}/arel.rbs #{export}"
        sh "cp -a out/#{version}/_active_record_relation.rbs #{export}"
        sh "rm #{export}/active_record/railtie.rbs"
        sh "cat out/#{version}/active_record/base.rbs | grep -v ActiveStorage > #{export}/active_record/base.rbs"

        Pathname(export).join("EXTERNAL_TODO.rbs").write(<<~RBS)
          # !!! GENERATED CODE !!!
          # Please see generators/rails-generator

          module PG
            class SimpleDecoder
            end
          end
          module GlobalID
            module Identification
            end
            module FixtureSet
            end
          end
        RBS

        generate_test_script(
          gem: :activerecord,
          version: version,
          export: export,
          stdlib_dependencies: stdlib_dependencies,
          gem_dependencies: gem_dependencies,
          rails_dependencies: rails_dependencies,
        )

        Pathname(export).join('_test').join('test.rb').write(<<~RUBY)
          # !!! GENERATED CODE !!!
          # Please see generators/rails-generator

          class User < ActiveRecord::Base
          end

          user = User.new
        RUBY

        Pathname(export).join('_test').join('test.rbs').write(<<~RBS)
          # !!! GENERATED CODE !!!
          # Please see generators/rails-generator

          class User < ActiveRecord::Base
          end
        RBS
      end

      desc "validate version=#{version} gem=active_record"
      task :validate do
        stdlib_opt = stdlib_dependencies.map{"-r #{_1}"}.join(" ")
        gem_opt = gem_dependencies.map{"-I ../../.gem_rbs_collection/#{_1}"}.join(" ")
        rails_opt = rails_dependencies.map{"-I export/#{_1}/#{version}"}.join(" ")
        sh "rbs #{stdlib_opt} #{gem_opt} #{rails_opt} -I #{export} validate --silent"
      end

      desc "install to ../../../gems/activerecord/#{version}"
      task :install do
        install_to = File.expand_path("../../../gems/activerecord/#{version}", __dir__)
        sh "rm -fr #{install_to}"
        sh "cp -a #{export} #{install_to}"
      end
    end
  end
end
