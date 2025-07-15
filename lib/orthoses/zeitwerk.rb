# frozen_string_literal: true

module Orthoses
  class Zeitwerk
    def initialize(loader)
      @loader = loader
    end

    def call
      tracer = Orthoses::CallTracer::Lazy.new
      tracer.trace('Zeitwerk::Cref#set') do
        @loader.call
      end.tap do |store|
        tracer.captures.each do |capture|
          value = capture.argument[:value]
          name = Orthoses::Utils.module_name(value) or next
          next unless value.is_a?(Module)

          store[name].header = "module #{name}"
        end
      end
    end
  end
end
