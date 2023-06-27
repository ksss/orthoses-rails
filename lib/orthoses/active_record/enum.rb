# frozen_string_literal: true

module Orthoses
  module ActiveRecord
    # <= 6.1
    #   def enum(definitions)
    # >= 7.0
    #   def enum(name = nil, values = nil, **options)
    class Enum
      def initialize(loader)
        @loader = loader
      end

      def call
        enum = CallTracer::Lazy.new
        store = enum.trace('ActiveRecord::Enum#enum') do
          @loader.call
        end

        enum.captures.each do |capture|
          base_name = Utils.module_name(capture.method.receiver) or next

          sig = "include #{base_name}::ActiveRecord_Enum_EnumMethods"
          if !store[base_name].body.include?(sig)
            store[base_name] << sig
          end

          if capture.argument[:definitions]
            # on rails 6
            definitions = capture.argument[:definitions].slice!(:_prefix, :_suffix, :_scopes, :_default)
            options = capture.argument[:definitions].transform_keys { |key| :"#{key[1..-1]}" }
            definitions.each { |name, values| _enum(store, base_name, name, values, **options) }
          else
            # on rails 7
            name = capture.argument[:name]
            values = capture.argument[:values]
            options = capture.argument[:options]
            if name
              # rails 7 style
              values, options = options, {} unless values
              _enum(store, base_name, name, values, **options)
            else
              # rails 6 style
              definitions = options.slice!(:_prefix, :_suffix, :_scopes, :_default)
              options.transform_keys! { |key| :"#{key[1..-1]}" }

              definitions.each { |name, values| _enum(store, base_name, name, values, **options) }
            end
          end
        end

        store
      end

      private

      def _enum(store, base_name, name, values, prefix: nil, suffix: nil, **_options)
        name = name.to_s

        prefix = if prefix
          prefix == true ? "#{name}_" : "#{prefix}_"
        end

        suffix = if suffix
          suffix == true ? "_#{name}" : "_#{suffix}"
        end

        return_type_param = Hash === values ? "[String, String]" : "[String, Integer]"
        store[base_name] << "def self.#{name.pluralize}: () -> ActiveSupport::HashWithIndifferentAccess#{return_type_param}"

        pairs = values.respond_to?(:each_pair) ? values.each_pair : values.each_with_index
        pairs.each do |label, value|
          value_method_name = "#{prefix}#{label}#{suffix}"
          enum_methods_content = store["#{base_name}::ActiveRecord_Enum_EnumMethods"]
          enum_methods_content.header = "module #{base_name}::ActiveRecord_Enum_EnumMethods"
          enum_methods_content << "def #{value_method_name}?: () -> bool"
          enum_methods_content << "def #{value_method_name}!: () -> bool"
        end
      end
    end
  end
end
