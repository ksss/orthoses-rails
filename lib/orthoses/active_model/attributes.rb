# frozen_string_literal: true

module Orthoses
  module ActiveModel
    # < 7.0
    #   def attribute(name, type = Type::Value.new, **options)
    # >= 7.0
    #   def attribute(name, cast_type = nil, default: NO_DEFAULT_PROVIDED, **options)
    class Attributes
      DEFAULT_TYPES = {
        big_integer: '::Integer',
        binary: '::String',
        boolean: 'bool',
        date: '::Date',
        datetime: '::Time',
        decimal: '::BigDecimal',
        float: '::Float',
        immutable_string: '::String',
        integer: '::Integer',
        string: '::String',
        time: '::Time'
      }

      def initialize(loader)
        @loader = loader
      end

      def call
        attribute = CallTracer::Lazy.new
        store = attribute.trace('ActiveModel::Attributes::ClassMethods#attribute') do
          @loader.call
        end
        attribute.captures.each do |capture|
          receiver_name = Utils.module_name(capture.method.receiver) or next
          name = capture.argument[:name]
          active_model_version = Gem::Version.new(::ActiveModel::VERSION::STRING)
          cast_type =
            if active_model_version >= Gem::Version.new('7.1')
              # https://github.com/rails/rails/commit/608cbfae36b125d7962b7ed9083c9e9e6ce70b88
              capture.argument[:*].first
            elsif active_model_version >= Gem::Version.new('7.0')
              capture.argument[:cast_type]
            else
              capture.argument[:type]
            end

          return_type = DEFAULT_TYPES[cast_type] || 'untyped'

          generated_attribute_methods = "#{receiver_name}::ActiveModelGeneratedAttributeMethods"
          c = store[generated_attribute_methods]
          c.header = "module #{generated_attribute_methods}"
          c << "def #{name}: () -> #{return_type}?"
          c << "def #{name}=: (untyped) -> untyped"

          unless store[receiver_name].body.include?("include #{generated_attribute_methods}")
            store[receiver_name] << "include #{generated_attribute_methods}"
          end
        end

        store
      end
    end
  end
end
