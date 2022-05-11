# frozen_string_literal: true

module Orthoses
  module ActiveSupport
    class Concern
      def initialize(loader)
        @loader = loader
      end

      def call
        extended = CallTracer.new
        store = extended.trace(::ActiveSupport::Concern.method(:extended)) do
          @loader.call
        end
        extended.result.each do |method, argument|
          store[argument[:base].to_s] << "extend ActiveSupport::Concern"
        end
        store
      end
    end
  end
end
