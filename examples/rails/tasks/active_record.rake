namespace :export do
  namespace :active_record do
    task all: VERSIONS

    stdlib_dependencies = %w[time monitor singleton logger mutex_m json date benchmark digest forwardable did_you_mean openssl socket]
    gem_dependencies = %w[nokogiri]
    rails_dependencies = %w[activesupport activemodel activejob]

    VERSIONS.each do |version|
      task version do |t|
        export = "export/activerecord/#{version}"

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

        stdlib_opt = stdlib_dependencies.map{"-r #{_1}"}.join(" ")
        gem_opt = gem_dependencies.map{"-I ../../.gem_rbs_collection/#{_1}"}.join(" ")
        rails_opt = rails_dependencies.map{"-I export/#{_1}/#{version}"}.join(" ")
        sh "rbs #{stdlib_opt} #{gem_opt} #{rails_opt} -I #{export} validate --silent"
      end
    end
  end
end
