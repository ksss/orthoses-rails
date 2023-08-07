# frozen_string_literal: true

module Orthoses
  module ActiveSupport
    # def alias_attribute(new_name, old_name)
    class Aliasing
      def initialize(loader)
        @loader = loader
      end

      def call
        alias_attribute = CallTracer::Lazy.new

        store =
          alias_attribute.trace('Module#alias_attribute') do
            @loader.call
          end

        alias_attribute.captures.each do |capture|
          base_mod_name = Utils.module_name(capture.method.receiver) or next
          new_name = capture.argument[:new_name]

          content = store[base_mod_name]
          # TODO: Shold use alias? But, it has risc of undefined method
          content << "def #{new_name}: () -> untyped"
          content << "def #{new_name}?: () -> bool"
          content << "def #{new_name}=: (untyped) -> untyped"
        end

        store
      end
    end
  end
end
