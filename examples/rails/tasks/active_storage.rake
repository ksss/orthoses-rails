require 'rbs'

namespace :export do
  namespace :active_storage do
    task all: VERSIONS

    stdlib_dependencies = %w[time monitor singleton logger mutex_m json date benchmark digest forwardable did_you_mean openssl socket]
    gem_dependencies = %w[nokogiri]
    rails_dependencies = %w[activesupport activemodel activejob activerecord]

    VERSIONS.each do |version|
      task version do |t|
        export = "export/activestorage/#{version}"

        sh "rm -fr #{export}"
        sh "mkdir -p #{export}"

        # minimum
        sh "cp -a out/#{version}/active_storage.rbs #{export}"
        sh "cp -a out/#{version}/active_storage #{export}"
        sh "rm #{export}/active_storage/engine.rbs"
        decls = RBS::Parser.parse_signature(RBS::Buffer.new(
          content: File.read("out/#{version}/active_record/base.rbs"),
          name: "out/#{version}/active_record/base.rbs"
        )).map do |decl|
          decl.members.select! do |member|
            case member
            when RBS::AST::Members::Mixin
              member.name.to_s.include?("ActiveStorage")
            end
          end
          decl
        end
        File.open("#{export}/active_record_base.rbs", "w+") do |f|
          RBS::Writer.new(out: f).write(decls)
        end

        # TODO: remove after support action_controller
        sh "rm #{export}/active_storage/base_controller.rbs"
        sh "rm -fr #{export}/active_storage/blobs"
        sh "rm -fr #{export}/active_storage/representations"
        sh "rm #{export}/active_storage/direct_uploads_controller.rbs"
        sh "rm #{export}/active_storage/disk_controller.rbs"
        sh "rm #{export}/active_storage/streaming.rbs"


        Pathname(export).join("EXTERNAL_TODO.rbs").write(<<~RBS)

        RBS

        stdlib_opt = stdlib_dependencies.map{"-r #{_1}"}.join(" ")
        gem_opt = gem_dependencies.map{"-I ../../.gem_rbs_collection/#{_1}"}.join(" ")
        rails_opt = rails_dependencies.map{"-I export/#{_1}/#{version}"}.join(" ")
        sh "rbs #{stdlib_opt} #{gem_opt} #{rails_opt} -I #{export} validate --silent"
      end
    end
  end
end
