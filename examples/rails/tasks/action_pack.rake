stdlib_dependencies = %w[benchmark date digest json logger monitor mutex_m pathname singleton time minitest securerandom ipaddr did_you_mean uri cgi]
gem_dependencies = %w[nokogiri i18n rack rails-dom-testing]
rails_dependencies = %w[activesupport actionview]

VERSIONS.each do |version|
  namespace version do
    namespace :action_pack do
      export = "export/actionpack/#{version}"

      desc "export to #{export}"
      task :export do
        sh "rm -fr #{export}"
        sh "mkdir -p #{export}"

        sh "cp -a out/#{version}/action_pack.rbs #{export}"
        sh "cp -a out/#{version}/action_pack #{export}"
        sh "cp -a out/#{version}/action_controller.rbs #{export}"
        sh "cp -a out/#{version}/action_controller #{export}"
        sh "cp -a out/#{version}/action_dispatch.rbs #{export}"
        sh "cp -a out/#{version}/action_dispatch #{export}"
        sh "cp -a out/#{version}/abstract_controller.rbs #{export}"
        sh "cp -a out/#{version}/abstract_controller #{export}"
        sh "cp -a out/#{version}/mime.rbs #{export}"
        sh "cp -a out/#{version}/mime #{export}"

        sh "rm #{export}/action_controller/railtie.rbs"
        sh "rm #{export}/action_dispatch/railtie.rbs"

        Pathname(export).join("EXTERNAL_TODO.rbs").write(<<~RBS)
          # !!! GENERATED CODE !!!
          # Please see generators/rails-generator

          class Ripper
          end

          class Delegator
          end

          class SimpleDelegator < ::Delegator
          end

          class ActionDispatch::Cookies::CookieJar
            def to_h: () -> Hash[untyped, untyped]
          end

          module Rack
            module Cache
              class EntityStore
              end
              class MetaStore
              end
            end
            module Session
              class Dalli
              end
            end
            module Test
              class UploadedFile
              end
            end
          end
        RBS
      end

      desc "validate version=#{version} gem=action_pack"
      task :validate do
        validate(
          stdlib_dependencies: stdlib_dependencies,
          gem_dependencies: gem_dependencies,
          rails_dependencies: rails_dependencies,
          version: version,
          export: export
        )
      end

      desc "install to ../../../gems/actionpack/#{version}"
      task :install do
        install_to = File.expand_path("../../../gems/actionpack/#{version}", __dir__)
        sh "rm -fr #{install_to}"
        sh "cp -a #{export} #{install_to}"
      end
    end
  end
end
