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
        mattr_reader = Orthoses::CallTracer.new
        mattr_writer = Orthoses::CallTracer.new

        require 'active_support/core_ext/module/attribute_accessors.rb'
        result = mattr_reader.trace(::Module.instance_method(:mattr_reader)) do
          mattr_writer.trace(::Module.instance_method(:mattr_writer)) do
            @loader.call
          end
        end

        mattr_reader.result.each do |method, argument|
          base = method.receiver.to_s
          methods = []
          argument[:syms].each do |sym|
            next unless @if.nil? || @if.call(method, sym)

            methods << "def self.#{sym}: () -> untyped"
            if argument[:instance_reader] && argument[:instance_accessor]
              methods << "def #{sym}: () -> untyped"
            end
          end
          next if methods.empty?

          result[base].concat(methods)
        end

        mattr_writer.result.each do |method, argument|
          base = method.receiver.to_s
          methods = []
          argument[:syms].each do |sym|
            next unless @if.nil? || @if.call(method, sym)

            methods << "def self.#{sym}=: (untyped val) -> untyped"
            if argument[:instance_writer] && argument[:instance_accessor]
              methods << "def #{sym}=: (untyped val) -> untyped"
            end
          end
          next if methods.empty?

          result[base].concat(methods)
        end

        result
      end
    end
  end
end
