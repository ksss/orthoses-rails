stdlib_dependencies = %w[benchmark date digest forwardable json logger monitor mutex_m singleton time]
gem_dependencies = %w[nokogiri]
rails_dependencies = %w[activesupport]

VERSIONS.each do |version|
  namespace version do
    namespace :active_model do
      export = "export/activemodel/#{version}"

      desc "export to #{export}"
      task :export do
        sh "rm -fr #{export}"
        sh "mkdir -p #{export}"

        sh "cp -a out/#{version}/active_model.rbs #{export}"
        sh "cp -a out/#{version}/active_model #{export}"
        sh "rm #{export}/active_model/railtie.rbs"

        Pathname(export).join("EXTERNAL_TODO.rbs").write(<<~RBS)
          class Delegator
          end
          class SimpleDelegator < Delegator
          end
        RBS
      end

      desc "validate version=#{version} gem=active_model"
      task :validate do
        stdlib_opt = stdlib_dependencies.map{"-r #{_1}"}.join(" ")
        gem_opt = gem_dependencies.map{"-I ../../.gem_rbs_collection/#{_1}"}.join(" ")
        rails_opt = rails_dependencies.map{"-I export/#{_1}/#{version}"}.join(" ")
        sh "rbs #{stdlib_opt} #{gem_opt} #{rails_opt} -I #{export} validate --silent"
      end
    end
  end
end
