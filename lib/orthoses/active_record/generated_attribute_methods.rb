# frozen_string_literal: true

module Orthoses
  module ActiveRecord
    class GeneratedAttributeMethods
      TARGET_TYPE_MAP = {
        "attribute?" => "() -> bool",
        "attribute_before_last_save" => "() -> %<opt>s",
        "attribute_before_type_cast" => "() -> %<type>s",
        "attribute_came_from_user?" => "() -> bool",
        "attribute_change" => "() -> [%<opt>s, %<opt>s]",
        "attribute_change_to_be_saved" => "() -> Array[%<opt>s]?",
        "attribute_changed?" => "() -> bool",
        "attribute_for_database" => "() -> %<type>s",
        "attribute_in_database" => "() -> %<opt>s",
        "attribute_previous_change" => "() -> Array[%<opt>s]?",
        "attribute_previously_changed?" => "() -> bool",
        "attribute_previously_was" => "() -> %<opt>s",
        "attribute_was" => "() -> %<opt>s",
        "attribute_will_change!" => "() -> void",
        "clear_attribute_change" => "() -> void",
        "restore_attribute!" => "() -> void",
        "saved_change_to_attribute" => "() -> Array[%<opt>s]?",
        "saved_change_to_attribute?" => "() -> bool",
        "will_save_change_to_attribute?" => "() -> bool",
      }

      def initialize(loader, target_type_map: TARGET_TYPE_MAP)
        @loader = loader
        @target_type_map = target_type_map
      end

      def call
        @loader.call.tap do |store|
          ::ActiveRecord::Base.descendants.each do |klass|
            next if klass.abstract_class?

            base_klass_name = Utils.module_name(klass) || next
            begin
              klass.columns
            rescue ::ActiveRecord::StatementInvalid => e
              Orthoses.logger.warn(e.to_s)
              next
            end

            lines = []
            klass.columns_hash.each do |name, col|
              req = ActiveRecord.sql_type_to_rbs(col.type)
              opt = "#{req}?"
              type = col.null ? opt : req

              lines << "attr_accessor #{name}: #{type}"
              attribute_method_patterns(::ActiveRecord::Base).each do |matcher|
                tmpl = @target_type_map[matcher.proxy_target] or next
                lines << "def #{matcher.method_name(name)}: #{tmpl % {type: type, opt: opt}}"
              end
            end
            klass.attribute_aliases.each do |alias_name, column_name|
              attribute_method_patterns(::ActiveRecord::Base).each do |matcher|
                lines << "alias #{matcher.method_name(alias_name)} #{matcher.method_name(column_name)}"
              end
            end

            generated_attribute_methods = "#{base_klass_name}::GeneratedAttributeMethods"
            store[base_klass_name] << "include #{generated_attribute_methods}"

            store[generated_attribute_methods].header = "module #{generated_attribute_methods}"
            store[generated_attribute_methods].concat(lines)
          end
        end
      end

      private

      def attribute_method_patterns(const)
        if const.respond_to?(:attribute_method_patterns)
          const.attribute_method_patterns
        else
          const.attribute_method_matchers.each do |matcher|
            def matcher.proxy_target
              target
            end
          end
        end
      end
    end
  end
end
