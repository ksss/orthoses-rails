# frozen_string_literal: true

module Orthoses
  module ActiveSupport
    class TimeWithZone
      def initialize(loader)
        @loader = loader
      end

      # Time <= (known Time)
      # TimeWithZone <= (known TimeWithZone, known Time, core Time)
      def call
        store = @loader.call

        time_with_zone_store = store["ActiveSupport::TimeWithZone"]
        each_line_from_core_time_definition(store) do |line|
          time_with_zone_store << line
        end

        store
      end

      private

      NOT_DELEGATE_METHODS = Set.new(%i[
        utc
        getgm
        getutc
        gmtime
        localtime
      ])

      TYPE_MERGE_METHODS = Set.new(%i[
        +
        -
      ])

      def each_line_from_core_time_definition(store)
        type_name_time = TypeName("::Time")
        type_name_time_with_zone = TypeName("::ActiveSupport::TimeWithZone")
        env = Utils.rbs_environment(collection: true, cache: false)
        env << store["Time"].to_decl
        env << store["DateAndTime"].to_decl
        env << store["DateAndTime::Zones"].to_decl
        env << store["DateAndTime::Calculations"].to_decl
        env << store["DateAndTime::Compatibility"].to_decl
        env << store["ActiveSupport"].to_decl
        env << store["ActiveSupport::TimeZone"].to_decl
        env << store["ActiveSupport::Duration"].to_decl
        env << store["ActiveSupport::TimeWithZone"].to_decl

        builder = RBS::DefinitionBuilder.new(env: env.resolve_type_names)
        one_ancestors = builder.ancestor_builder.one_instance_ancestors(type_name_time)
        one_ancestors.included_modules.each do |included_module|
          yield "include #{included_module.source.name}"
        end
        twz_methods = builder.build_instance(type_name_time_with_zone).methods
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
            method_types = definition_method.method_types

            if TYPE_MERGE_METHODS.include?(sym)
              if twz_definition_method = twz_methods[sym]
                twz_definition_method.defs.each do |type_def|
                  if type_def.implemented_in == type_name_time_with_zone
                    method_types << type_def.type
                  end
                end
              end
            end
            yield "def #{sym}: #{method_types.join(" | ")}"
          else
            yield "alias #{sym} #{definition_method.alias_of.defs.first.member.name}"
          end
        end
      end
    end
  end
end
