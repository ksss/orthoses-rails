# frozen_string_literal: true

module Orthoses
  module ActiveSupport
    class Concern
      def initialize(loader)
        @loader = loader
      end

      def call
        target_method = begin
          ::ActiveSupport::Concern.method(:extended)
        rescue NameError => err
          Orthoses.logger.warn("Run `require 'active_support/concern'` and retry because #{err}")
          require 'active_support/concern'
          retry
        end

        extended = CallTracer.new
        store = extended.trace(target_method) do
          @loader.call
        end
        extended.result.each do |method, argument|
          base_name = Orthoses::Utils.module_name(argument[:base])
          next unless base_name
          store[argument[:base].to_s] << "extend ActiveSupport::Concern"
        end
        store
      end
    end
  end
end
