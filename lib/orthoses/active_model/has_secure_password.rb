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
        target_method = ::ActiveRecord::Base.method(:has_secure_password)
        call_tracer = Orthoses::CallTracer.new

        result = call_tracer.trace(target_method) do
          @loader.call
        end

        call_tracer.result.each do |method, argument|
          base = method.receiver.to_s
          if argument[:attribute].nil? # < 6.0
            result[base].delete_if { |line| line == "include ActiveModel::SecurePassword::InstanceMethodsOnActivation" }
          else
            result[base].delete_if { |line| line.start_with?("include #<InstanceMethodsOnActivation:") }
          end
          attribute = argument[:attribute] || :password
          mod_name = "ActiveModel_SecurePassword_InstanceMethodsOnActivation_#{attribute}"
          lines = []
          lines << "attr_reader #{attribute}: String?"
          lines << "def #{attribute}=: (String) -> String"
          lines << "def #{attribute}_confirmation=: (String) -> String"
          lines << "def authenticate_#{attribute}: (String) -> (#{base} | false)"
          if attribute == :password
            lines << "alias authenticate authenticate_password"
          end
          result["module #{base}::#{mod_name}"].concat(lines)
          result[base] << "include #{mod_name}"
        end

        result
      end
    end
  end
end
