# frozen_string_literal: true

module Orthoses
  module ActiveRecord
    # def scope(name, body, &block)
    class Scope
      def initialize(loader)
        @loader = loader
      end

      def call
        scope = CallTracer.new
        store = scope.trace(::ActiveRecord::Scoping::Named::ClassMethods.instance_method(:scope)) do
          @loader.call
        end

        scope.captures.each do |capture|
          base_name = Utils.module_name(capture.method.receiver) or next

          name = capture.argument[:name]
          body = capture.argument[:body]

          definition = "#{name}: #{parameters_to_type(body.parameters)} -> #{base_name}::ActiveRecord_Relation"
          store[base_name] << "def self.#{definition}"
          store["#{base_name}::GeneratedRelationMethods"].header = "module #{base_name}::GeneratedRelationMethods"
          store["#{base_name}::GeneratedRelationMethods"] << "def #{definition}"
        end

        store
      end

      private

      def parameters_to_type(parameters)
        # @type var res: Array[String]
        res = []
        # @type var block: String?
        block = nil
        parameters.each do |(type, name)|
          case type
          when :req
            res << "untyped #{name}"
          when :opt
            res << "?untyped #{name}"
          when :keyreq
            res << "#{name}: untyped"
          when :key
            res << "?#{name}: untyped"
          when :rest
            res << "*untyped #{name}"
          when :keyrest
            res << "**untyped #{name}"
          when :block
            block = " { (*untyped) -> untyped }"
          else
            raise "unexpected: #{type}"
          end
        end
        "(#{res.join(", ")})#{block}"
      end
    end
  end
end
