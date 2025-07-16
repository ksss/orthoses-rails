# frozen_string_literal: true

module Orthoses
  module ActiveSupport
    class CoreExt
      class Concerning
        def initialize(loader)
          @loader = loader
        end

        def call
          tracer = ::Orthoses::CallTracer::Lazy.new
          tracer.trace('Module::Concerning#concern') do
            @loader.call
          end.tap do |store|
            tracer.captures.each do |capture|
              base = capture.method.receiver
              base_name = ::Orthoses::Utils.module_name(base) or next
              topic = capture.argument[:topic] or next
              store["#{base_name}::#{topic}"].header = "module #{base_name}::#{topic}"
            end
          end
        end
      end

      def initialize(loader)
        @loader = loader
      end

      def call
        @loader = Concerning.new(@loader)
        @loader.call
      end
    end
  end
end
