# frozen_string_literal: true

module Orthoses
  module ActiveSupport
    # class Class
    #   # >= v5.2
    #   def class_attribute(*attrs)
    #   # <= v6.0
    #   def class_attribute(*attrs, instance_accessor: true,
    #     instance_reader: instance_accessor, instance_writer: instance_accessor, instance_predicate: true, default: nil)
    class ClassAttribute
      def initialize(loader, if: nil)
        @loader = loader
        @if = binding.local_variable_get(:if)
      end

      def call
        target_method = begin
          ::Class.instance_method(:class_attribute)
        rescue NameError => err
          Orthoses.logger.warn("Run `require 'active_support/core_ext/class/attribute'` and retry because #{err}")
          require 'active_support/core_ext/class/attribute'
          retry
        end
        call_tracer = Orthoses::CallTracer.new

        store = call_tracer.trace(target_method) do
          @loader.call
        end

        call_tracer.captures.each do |capture|
          receiver_name = Orthoses::Utils.module_name(capture.method.receiver)
          next unless receiver_name

          methods = []
          if ::ActiveSupport::VERSION::MAJOR < 6
            options = capture.argument[:attrs].extract_options!
            capture.argument[:instance_reader]    = options.fetch(:instance_accessor, true) && options.fetch(:instance_reader, true)
            capture.argument[:instance_writer]    = options.fetch(:instance_accessor, true) && options.fetch(:instance_writer, true)
            capture.argument[:instance_predicate] = options.fetch(:instance_predicate, true)
            capture.argument[:default_value]      = options.fetch(:default, nil)
          end

          content = store[receiver_name]

          capture.argument[:attrs].each do |name|
            next unless @if.nil? || @if.call(method, name)

            # skip internal attribute
            next if name.to_s.start_with?("_")
            next if name == :attribute_type_decorations
            next if name == :attributes_to_define_after_schema_loads

            methods << "def self.#{name}: () -> untyped"
            methods << "def self.#{name}?: () -> bool" if capture.argument[:instance_predicate]
            methods << "def self.#{name}=: (untyped value) -> untyped"
            methods << "def #{name}: () -> untyped" if capture.argument[:instance_reader]
            methods << "def #{name}?: () -> bool" if capture.argument[:instance_predicate] && capture.argument[:instance_reader]
            methods << "def #{name}=: (untyped value) -> untyped" if capture.argument[:instance_writer]
            # In RBS, `foo=` and attr_writer :foo cannot live together.
            content.body.delete_if { |line| line.start_with?("attr_writer #{name}:") }
          end
          next if methods.empty?

          content.concat(methods)
        end

        store
      end
    end
  end
end
