# frozen_string_literal: true

module Orthoses
  module ActiveModel
    # < 6.0
    #   def has_secure_password(options = {})
    # >= 6.0
    #   def has_secure_password(attribute = :password, validations: true)
    class HasSecurePassword
      def initialize(loader, if: nil)
        @loader = loader
        @if = binding.local_variable_get(:if)
      end

      def call
        call_tracer = CallTracer::Lazy.new

        store = call_tracer.trace('ActiveModel::SecurePassword::ClassMethods#has_secure_password') do
          @loader.call
        end

        call_tracer.captures.each do |capture|
          next unless capture.method.receiver.kind_of?(Class)
          base_name = Utils.module_name(capture.method.receiver)
          next unless base_name

          attribute = capture.argument[:attribute] || :password
          full_name = if ::ActiveModel::VERSION::MAJOR < 6
            "ActiveModel::SecurePassword::InstanceMethodsOnActivation"
          else
            "#{base_name}::ActiveModel_SecurePassword_InstanceMethodsOnActivation_#{attribute}"
          end

          lines = []
          lines << "attr_reader #{attribute}: String?"
          lines << "def #{attribute}=: (String) -> String"
          lines << "def #{attribute}_confirmation=: (String) -> String"
          lines << "def authenticate_#{attribute}: (String) -> (#{base_name} | false)"
          if attribute == :password
            lines << "alias authenticate authenticate_password"
          end
          store[full_name].header = "module #{full_name}"
          store[full_name].concat(lines)
          store[base_name] << "include #{full_name}"
        end

        store
      end
    end
  end
end
