stdlib_dependencies = %w[benchmark date digest json logger monitor mutex_m pathname singleton time minitest securerandom ipaddr did_you_mean forwardable openssl socket uri cgi]
gem_dependencies = %w[nokogiri i18n rack rails-dom-testing]
rails_dependencies = %w[actionpack actionview activejob activemodel activerecord activestorage activesupport]

VERSIONS.each do |version|
  namespace version do
    namespace :railties do
      export = "export/railties/#{version}"

      desc "export to #{export}"
      task :export do
        sh "rm -fr #{export}"
        sh "mkdir -p #{export}"

        sh "cp -a out/#{version}/railties_mixin #{export}"

        # FIXME
        Dir.glob("#{export}/railties_mixin/*").grep_v(/action|active/).each do |rm_dir|
          sh "rm -fr #{rm_dir}"
        end
        sh "rm -fr #{export}/railties_mixin/active_record/connection_adapters"
      end

      desc "validate version=#{version} gem=railties"
      task :validate do
        validate(
          stdlib_dependencies: stdlib_dependencies,
          gem_dependencies: gem_dependencies,
          rails_dependencies: rails_dependencies,
          version: version,
          export: export
        )
      end

      desc "install to ../../../gems/railties/#{version}"
      task :install do
        install_to = File.expand_path("../../../gems/railties/#{version}", __dir__)
        sh "rm -fr #{install_to}"
        sh "cp -a #{export} #{install_to}"
      end
    end
  end
end
