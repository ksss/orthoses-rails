# frozen_string_literal: true

module Orthoses
  module ActionMailer
    class Base
      def initialize(loader)
        @loader = loader
      end

      def call
        @loader.call.tap do |store|
          ::ActionMailer::Base.descendants.each do |mailer_class|
            base_name = Utils.module_name(mailer_class) or next
            content = store[base_name]
            mailer_class.action_methods.each do |action_method|
              method_object = mailer_class.instance_method(action_method)
              parameters = method_parameters_to_rbs_method_type(method_object).to_s.gsub(' -> untyped', '')
              content << "def self.#{action_method}: #{parameters} -> ::ActionMailer::MessageDelivery"
            end
          end
        end
      end

      private

      def method_parameters_to_rbs_method_type(method_object)
        required_positionals = []
        optional_positionals = []
        rest_positionals = nil
        trailing_positionals = []
        required_keywords = {}
        optional_keywords = {}
        rest_keywords = nil
        requireds = required_positionals
        block = nil
        untyped = RBS::Types::Bases::Any.new(location: nil)

        method_object.parameters.each do |kind, name|
          case kind
          when :req
            requireds << ::RBS::Types::Function::Param.new(name: name, type: untyped)
          when :opt
            requireds = trailing_positionals
            optional_positionals << ::RBS::Types::Function::Param.new(name: name, type: untyped)
          when :rest
            requireds = trailing_positionals
            name = nil if name == :*
            rest_positionals = ::RBS::Types::Function::Param.new(name: name, type: untyped)
          when :keyreq
            required_keywords[name] = ::RBS::Types::Function::Param.new(name: nil, type: untyped)
          when :key
            optional_keywords[name] = ::RBS::Types::Function::Param.new(name: nil, type: untyped)
          when :keyrest
            rest_keywords = ::RBS::Types::Function::Param.new(name: name, type: untyped)
          when :block
            block = RBS::Types::Block.new(
              type: RBS::Types::Function.empty(untyped).update(rest_positionals: RBS::Types::Function::Param.new(name: nil, type: untyped)),
              required: true,
              self_type: nil
            )
          else
            raise "bug"
          end
        end

        function = ::RBS::Types::Function.new(
          required_positionals: required_positionals,
          optional_positionals: optional_positionals,
          rest_positionals: rest_positionals,
          trailing_positionals: trailing_positionals,
          required_keywords: required_keywords,
          optional_keywords: optional_keywords,
          rest_keywords: rest_keywords,
          return_type: untyped,
        )
        ::RBS::MethodType.new(
          location: nil,
          type_params: [],
          type: function,
          block: block
        )
      end
    end
  end
end
