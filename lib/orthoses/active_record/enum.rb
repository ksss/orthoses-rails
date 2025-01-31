# frozen_string_literal: true

module Orthoses
  module ActiveRecord
    # <= 6.1
    #   def enum(definitions)
    # >= 7.0
    #   def enum(name = nil, values = nil, **options)
    class Enum
      def initialize(loader, strict_limit: 8)
        @loader = loader
        @strict_limit = strict_limit
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
        enum_methods_content = store["#{base_name}::ActiveRecord_Enum_EnumMethods"]
        enum_methods_content.header = "module #{base_name}::ActiveRecord_Enum_EnumMethods"

        pairs = (values.respond_to?(:each_pair) ? values.each_pair : values.each_with_index).to_h
        pairs.each do |label, value|
          value_method_name = "#{prefix}#{label}#{suffix}"
          enum_methods_content << "def #{value_method_name}?: () -> bool"
          enum_methods_content << "def #{value_method_name}!: () -> bool"

          value_method_alias = "#{prefix}#{label.to_s.gsub(/[\W&&[:ascii:]]+/, "_")}#{suffix}"
          if value_method_alias != value_method_name
            enum_methods_content << "def #{value_method_alias}?: () -> bool"
            enum_methods_content << "def #{value_method_alias}!: () -> bool"
          end
        end

        # Expressing type casting.
        overloads = [] #: Array[String]
        if pairs.length <= @strict_limit
          if pairs.keys.any? { |key| key.match?(/[^a-zA-Z_]/) }
            overloads << "(Symbol) -> void"
          else
            overloads << "(#{pairs.keys.map{|key|key.to_sym.inspect}.join(" | ")}) -> void"
          end
          overloads << "(#{pairs.keys.map{|key|key.to_s.inspect}.join(" | ")}) -> void"
          overloads << "(#{pairs.values.map(&:inspect).join(" | ")}) -> void"
          store[base_name] << "def #{name}: () -> (#{pairs.keys.map { |k| "\"#{k}\"" }.join(" | ")})"
          store[base_name] << "def #{name}=: #{overloads.join(" | ")}"
        else
          overloads << "(Symbol | String) -> void"
          overloads << "(#{pairs.values.map { |v| Orthoses::Utils.object_to_rbs(v) }.uniq.join(" | ")}) -> void"
          store[base_name] << "def #{name}: () -> String"
          store[base_name] << "def #{name}=: #{overloads.join(" | ")}"
        end
      end
    end
  end
end
