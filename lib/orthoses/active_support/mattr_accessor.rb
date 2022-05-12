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

        store = mattr_reader.trace(target_method(:mattr_reader)) do
          mattr_writer.trace(target_method(:mattr_writer)) do
            @loader.call
          end
        end

        mattr_reader.result.each do |method, argument|
          base = Orthoses::Utils.module_name(method.receiver) || next
          methods = []
          argument[:syms].each do |sym|
            next unless @if.nil? || @if.call(method, sym)

            methods << "def self.#{sym}: () -> untyped"
            if argument[:instance_reader] && argument[:instance_accessor]
              methods << "def #{sym}: () -> untyped"
            end
          end
          next if methods.empty?

          store[base].concat(methods)
        end

        mattr_writer.result.each do |method, argument|
          base = Orthoses::Utils.module_name(method.receiver) || next
          methods = []
          argument[:syms].each do |sym|
            next unless @if.nil? || @if.call(method, sym)

            methods << "def self.#{sym}=: (untyped val) -> untyped"
            if argument[:instance_writer] && argument[:instance_accessor]
              methods << "def #{sym}=: (untyped val) -> untyped"
            end
          end
          next if methods.empty?

          store[base].concat(methods)
        end

        store
      end

      def target_method(name)
        ::Module.instance_method(name)
      rescue NameError => err
        Orthoses.logger.warn("Run `require 'active_support/core_ext/module/attribute_accessors'` and retry because #{err}")
        require 'active_support/core_ext/module/attribute_accessors'
        retry
      end
    end
  end
end
