# frozen_string_literal: true

module Orthoses
  module ActiveSupport
    class Concern
      def initialize(loader)
        @loader = loader
      end

      def call
        extended = CallTracer.new
        result = extended.trace(::ActiveSupport::Concern.method(:extended)) do
          @loader.call
        end
        extended.result.each do |method, argument|
          result[argument[:base].to_s] << "extend ActiveSupport::Concern"
        end
        result
      end
    end
  end
end
