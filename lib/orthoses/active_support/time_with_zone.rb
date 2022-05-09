# frozen_string_literal: true

module Orthoses
  module ActiveSupport
    class TimeWithZone
      def initialize(loader)
        @loader = loader
      end

      LOAD_PATHS = [
        File.expand_path("known_sig/time.rbs", __dir__),
        File.expand_path("known_sig/active_support/time_with_zone.rbs", __dir__),
      ]

      # Time <= (known Time)
      # TimeWithZone <= (known TimeWithZone, known Time, core Time)
      def call
        store = Orthoses::LoadRBS.new(@loader, paths: LOAD_PATHS).call

        time_with_zone_store = store["ActiveSupport::TimeWithZone"]
        each_line_from_core_time_definition do |line|
          time_with_zone_store << line
        end

        store
      end

      private

      NOT_DELEGATE_METHODS = %i[
        utc
        getgm
        getutc
        gmtime
        localtime
      ]

      def each_line_from_core_time_definition
        type_name_time = TypeName("::Time")
        loader = RBS::EnvironmentLoader.new
        env = RBS::Environment.from_loader(loader)
        LOAD_PATHS.each do |path|
          RBS::Parser.parse_signature(File.read(path)).each do |decl|
            env << decl
          end
        end

        builder = RBS::DefinitionBuilder.new(env: env.resolve_type_names)
        one_ancestors = builder.ancestor_builder.one_instance_ancestors(type_name_time)
        one_ancestors.included_modules.each do |included_module|
          yield "include #{included_module.source.name}"
        end
        builder.build_instance(type_name_time).methods.each do |sym, definition_method|
          next if !definition_method.public?
          definition_method.defs.reject! do |type_def|
            type_def.implemented_in != type_name_time
          end
          next if definition_method.defs.empty?

          if !NOT_DELEGATE_METHODS.include?(sym)
            definition_method.method_types.each do |method_type|
              rt = method_type.type.return_type
              if rt.instance_of?(RBS::Types::ClassInstance) && rt.name.to_s == "::Time"
                rt.instance_variable_set(:@name, RBS::Types::Bases::Self.new(location: nil))
              end
            end
          end

          if definition_method.alias_of.nil?
            yield "def #{sym}: #{definition_method.method_types.join(" | ")}"
          else
            yield "alias #{sym} #{definition_method.alias_of.defs.first.member.name}"
          end
        end
      end
    end
  end
end
