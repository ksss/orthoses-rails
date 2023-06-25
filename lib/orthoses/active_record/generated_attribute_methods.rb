# frozen_string_literal: true

module Orthoses
  module ActiveRecord
    class GeneratedAttributeMethods
      def initialize(loader)
        @loader = loader
      end

      def call
        @loader.call.tap do |store|
          ::ActiveRecord::Base.descendants.each do |klass|
            next if klass.abstract_class?

            name = Utils.module_name(klass) || next
            begin
              klass.columns
            rescue ::ActiveRecord::StatementInvalid => e
              Orthoses.logger.warn(e.to_s)
              next
            end

            lines = klass.columns.flat_map do |col|
              req = ActiveRecord.sql_type_to_rbs(col.type)
              opt = "#{req}?"
              type = col.null ? opt : req

              [
                "def #{col.name}: () -> #{type}",
                "def #{col.name}=: (#{type}) -> #{type}",
                "def #{col.name}?: () -> bool",
                "def #{col.name}_changed?: () -> bool",
                "def #{col.name}_change: () -> [#{opt}, #{opt}]",
                "def #{col.name}_will_change!: () -> void",
                "def #{col.name}_was: () -> #{opt}",
                "def #{col.name}_previously_changed?: () -> bool",
                "def #{col.name}_previous_change: () -> Array[#{opt}]?",
                "def #{col.name}_previously_was: () -> #{opt}",
                "def #{col.name}_before_last_save: () -> #{opt}",
                "def #{col.name}_change_to_be_saved: () -> Array[#{opt}]?",
                "def #{col.name}_in_database: () -> #{opt}",
                "def saved_change_to_#{col.name}: () -> Array[#{opt}]?",
                "def saved_change_to_#{col.name}?: () -> bool",
                "def will_save_change_to_#{col.name}?: () -> bool",
                "def restore_#{col.name}!: () -> void",
                "def clear_#{col.name}_change: () -> void",
              ]
            end
            generated_attribute_methods = "#{name}::AttributeMethods::GeneratedAttributeMethods"
            store[name] << "include #{generated_attribute_methods}"

            store["#{name}::AttributeMethods"].header = "module #{name}::AttributeMethods"
            store[generated_attribute_methods].header = "module #{generated_attribute_methods}"
            store[generated_attribute_methods].concat(lines)
          end
        end
      end
    end
  end
end
