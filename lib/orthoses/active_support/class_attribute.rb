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

        call_tracer.result.each do |method, argument|
          receiver_name = Orthoses::Utils.module_name(method.receiver)
          next unless receiver_name

          methods = []
          if ::ActiveSupport::VERSION::MAJOR < 6
            options = argument[:attrs].extract_options!
            argument[:instance_reader]    = options.fetch(:instance_accessor, true) && options.fetch(:instance_reader, true)
            argument[:instance_writer]    = options.fetch(:instance_accessor, true) && options.fetch(:instance_writer, true)
            argument[:instance_predicate] = options.fetch(:instance_predicate, true)
            argument[:default_value]      = options.fetch(:default, nil)
          end
          argument[:attrs].each do |name|
            next unless @if.nil? || @if.call(method, name)

            # skip internal attribute
            next if name.to_s.start_with?("_")
            next if name == :attribute_type_decorations
            next if name == :attributes_to_define_after_schema_loads

            methods << "def self.#{name}: () -> untyped"
            methods << "def self.#{name}?: () -> bool" if argument[:instance_predicate]
            methods << "def self.#{name}=: (untyped value) -> untyped"
            methods << "def #{name}: () -> untyped" if argument[:instance_reader]
            methods << "def #{name}?: () -> bool" if argument[:instance_predicate] && argument[:instance_reader]
            methods << "def #{name}=: (untyped value) -> untyped" if argument[:instance_writer]
          end
          next if methods.empty?

          store[receiver_name].concat(methods)
        end

        store
      end
    end
  end
end
