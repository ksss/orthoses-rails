# frozen_string_literal: true

module Orthoses
  module ActiveRecord
    class Persistence
      def initialize(loader)
        @loader = loader
      end

      def call
        @loader.call.tap do |store|
          ::ActiveRecord::Base.descendants.each do |klass|
            next if klass.abstract_class?
            base_name = Utils.module_name(klass) or next

            attributes = klass.columns_hash.map do |key, col|
              req = ActiveRecord.sql_type_to_rbs(col.type)
              opt = "#{req}?"
              [key.to_s, col.null ? opt : req]
            end.to_h

            klass.attribute_aliases.each do |alias_name, column_name|
              alias_value = attributes[column_name.to_s] or next
              attributes[alias_name.to_s] = alias_value
            end

            optional_definitions = attributes.map do |name, type|
              "?#{name}: #{type}"
            end.join(", ")

            class_methods_name = "#{base_name}::ActiveRecord_Persistence_ClassMethods"
            store[base_name] << "extend #{class_methods_name}"
            store[class_methods_name].header = "module #{class_methods_name}"

            %i[create create! build].each do |method|
              method = <<~RBS
                def #{method}: (#{optional_definitions}, **untyped) ?{ (#{base_name}) -> void } -> #{base_name}
                             | (::Array[Hash[Symbol, untyped]]) ?{ (#{base_name}) -> void } -> ::Array[#{base_name}]
              RBS
              store[class_methods_name] << method
            end
          end
        end
      end
    end
  end
end
