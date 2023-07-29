# frozen_string_literal: true

module Orthoses
  module ActiveRecord
    # def has_secure_token(attribute = :token, length: MINIMUM_TOKEN_LENGTH)
    class SecureToken
      def initialize(loader)
        @loader = loader
      end

      def call
        has_secure_token = CallTracer::Lazy.new
        store = has_secure_token.trace('ActiveRecord::SecureToken::ClassMethods#has_secure_token') do
          @loader.call
        end

        has_secure_token.captures.each do |capture|
          base_name = Utils.module_name(capture.method.receiver) or next
          attribute = capture.argument[:attribute]

          store[base_name] << "def regenerate_#{attribute}: () -> bool"
        end

        store
      end
    end
  end
end
