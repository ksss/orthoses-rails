namespace :export do
  namespace :active_job do
    task all: VERSIONS

    stdlib_dependencies = %w[time monitor singleton logger mutex_m json date benchmark digest]
    gem_dependencies = %w[nokogiri]
    rails_dependencies = %w[activesupport]

    VERSIONS.each do |version|
      task version do |t|
        export = "export/activejob/#{version}"

        sh "rm -fr #{export}"
        sh "mkdir -p #{export}"

        sh "cp -a out/#{version}/active_job.rbs #{export}"
        sh "cp -a out/#{version}/active_job #{export}"
        sh "rm #{export}/active_job/railtie.rbs"

        Pathname(export).join("EXTERNAL_TODO.rbs").write(<<~RBS)
          module Que
            class Job
            end
          end
        RBS

        stdlib_opt = stdlib_dependencies.map{"-r #{_1}"}.join(" ")
        gem_opt = gem_dependencies.map{"-I ../../.gem_rbs_collection/#{_1}"}.join(" ")
        rails_opt = rails_dependencies.map{"-I export/#{_1}/#{version}"}.join(" ")
        sh "rbs #{stdlib_opt} #{gem_opt} #{rails_opt} -I #{export} validate --silent"
      end
    end
  end
end
