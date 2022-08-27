# frozen_string_literal: true

module Orthoses
  module ActiveSupport
    # <= 6.1
    #   def config_accessor(*names, instance_reader: true, instance_writer: true, instance_accessor: true)
    # >= 7
    #   def config_accessor(*names, instance_reader: true, instance_writer: true, instance_accessor: true, default: nil)
    class Configurable
      def initialize(loader)
        @loader = loader
      end

      def call
        config_accessor = CallTracer::Lazy.new

        store = config_accessor.trace('ActiveSupport::Configurable::ClassMethods#config_accessor') do
          @loader.call
        end
        config_accessor.captures.each do |capture|
          mod_name = Utils.module_name(capture.method.receiver) or next
          content = store[mod_name]
          capture.argument[:names].each do |name|
            content << "def self.#{name}: () -> untyped"
            content << "def self.#{name}=: (untyped value) -> untyped"
            if capture.argument[:instance_accessor]
              content << "def #{name}: () -> untyped" if capture.argument[:instance_reader]
              content << "def #{name}=: (untyped value) -> untyped" if capture.argument[:instance_writer]
            end
          end
        end

        store
      end
    end
  end
end
