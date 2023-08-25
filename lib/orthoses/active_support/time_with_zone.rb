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
        time_with_zone_store.body.replace(filter_decl(time_with_zone_store))
        each_line_from_core_time_definition(store) do |line|
          time_with_zone_store << line
        end

        store
      end

      private

      TYPE_MERGE_METHODS = Set.new(%i[
        +
        -
      ])

      TIME_MODULES = [
        TypeName("::Time"),
        TypeName("::DateAndTime::Zones"),
        TypeName("::DateAndTime::Calculations"),
        TypeName("::DateAndTime::Compatibility")
      ]

      def filter_decl(time_with_zone_store)
        writer = RBS::Writer.new(out: StringIO.new)
        time_with_zone_store.to_decl.members.each do |member|
          # ActiveSupport::TimeWithZone.name has been deprecated
          next if member.instance_of?(RBS::AST::Members::MethodDefinition) && member.kind == :singleton && member.name == :name
          writer.write_member(member)
        end
        writer.out.string.each_line.to_a
      end

      def add_signature(env, content)
        buffer, directives, decls = RBS::Parser.parse_signature(content.to_rbs)
        env.add_signature(buffer: buffer, directives: directives, decls: decls)
      end

      def each_line_from_core_time_definition(store)
        type_name_time = TypeName("::Time")
        type_name_time_with_zone = TypeName("::ActiveSupport::TimeWithZone")
        env = Utils.rbs_environment(collection: true, cache: false)

        add_signature(env, store["Time"])
        add_signature(env, store["DateAndTime"])
        add_signature(env, store["DateAndTime::Zones"])
        add_signature(env, store["DateAndTime::Calculations"])
        add_signature(env, store["DateAndTime::Compatibility"])
        add_signature(env, store["ActiveSupport"])
        add_signature(env, store["ActiveSupport::TimeZone"])
        add_signature(env, store["ActiveSupport::Duration"])
        add_signature(env, store["ActiveSupport::TimeWithZone"])

        builder = RBS::DefinitionBuilder.new(env: env.resolve_type_names)
        twz_methods = builder.build_instance(type_name_time_with_zone).methods
        builder.build_instance(type_name_time).methods.each do |sym, definition_method|
          next if twz_methods.has_key?(sym) && !TYPE_MERGE_METHODS.include?(sym)
          next if !definition_method.public?

          # delegate to ::Time method
          definition_method.defs.select! do |type_def|
            TIME_MODULES.include?(type_def.implemented_in)
          end
          next if definition_method.defs.empty?

          definition_method.method_types.each do |method_type|
            rt = method_type.type.return_type
            if rt.instance_of?(RBS::Types::ClassInstance) && rt.name.to_s == "::Time"
              rt.instance_variable_set(:@name, RBS::Types::Bases::Self.new(location: nil))
            end
          end

          if definition_method.alias_of.nil?
            method_types = definition_method.method_types

            # merge method types (e.g. :+, :-
            # TimeWithZone -delegate-> Time(core_ext) -delegate-> Time(core)
            if TYPE_MERGE_METHODS.include?(sym)
              if twz_definition_method = twz_methods[sym]
                twz_definition_method.defs.each do |type_def|
                  if type_def.implemented_in == type_name_time_with_zone
                    method_types.unshift(type_def.type)
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
