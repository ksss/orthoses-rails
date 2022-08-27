# frozen_string_literal: true

module Orthoses
  module ActiveSupport
    # class Module
    #   def mattr_reader(*syms, instance_reader: true, instance_accessor: true, default: nil, location: nil)
    #   def mattr_writer(*syms, instance_writer: true, instance_accessor: true, default: nil, location: nil)
    #   def mattr_accessor(*syms, instance_reader: true, instance_writer: true, instance_accessor: true, default: nil, &blk)
    class MattrAccessor
      def initialize(loader, if: nil)
        @loader = loader
        @if = binding.local_variable_get(:if)
      end

      def call
        mattr_reader = CallTracer::Lazy.new
        mattr_writer = CallTracer::Lazy.new

        store = mattr_reader.trace('Module#mattr_reader') do
          mattr_writer.trace('Module#mattr_writer') do
            @loader.call
          end
        end

        mattr_reader.captures.each do |capture|
          base = Orthoses::Utils.module_name(capture.method.receiver) || next
          methods = []
          capture.argument[:syms].each do |sym|
            next unless @if.nil? || @if.call(method, sym)

            methods << "def self.#{sym}: () -> untyped"
            if capture.argument[:instance_reader] && capture.argument[:instance_accessor]
              methods << "def #{sym}: () -> untyped"
            end
          end
          next if methods.empty?

          store[base].concat(methods)
        end

        mattr_writer.captures.each do |capture|
          base = Orthoses::Utils.module_name(capture.method.receiver) || next
          methods = []
          capture.argument[:syms].each do |sym|
            next unless @if.nil? || @if.call(method, sym)

            methods << "def self.#{sym}=: (untyped val) -> untyped"
            if capture.argument[:instance_writer] && capture.argument[:instance_accessor]
              methods << "def #{sym}=: (untyped val) -> untyped"
            end
          end
          next if methods.empty?

          store[base].concat(methods)
        end

        store
      end
    end
  end
end
