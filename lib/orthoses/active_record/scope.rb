# frozen_string_literal: true

module Orthoses
  module ActiveRecord
    # def scope(name, body, &block)
    class Scope
      def initialize(loader)
        @loader = loader
      end

      def call
        scope = CallTracer::Lazy.new
        store = scope.trace('ActiveRecord::Scoping::Named::ClassMethods#scope') do
          @loader.call
        end

        scope.captures.each do |capture|
          base_name = Utils.module_name(capture.method.receiver) or next

          name = capture.argument[:name]
          body = capture.argument[:body]

          definition = "#{name}: #{parameters_to_type(parameters(body))} -> #{base_name}::ActiveRecord_Relation"
          store[base_name] << "def self.#{definition}"
          store["#{base_name}::GeneratedRelationMethods"].header = "module #{base_name}::GeneratedRelationMethods"
          store["#{base_name}::GeneratedRelationMethods"] << "def #{definition}"
        end

        store
      end

      private

      def parameters_to_type(parameters)
        # foo(...)
        if parameters in [[:rest, :*], [:keyrest, :**], [:block, :&]]
          return "(?)"
        end
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
            res << "*untyped"
          when :keyrest
            res << "**untyped"
          when :block
            block = " { (*untyped) -> untyped }"
          else
            raise "unexpected: #{type}"
          end
        end
        "(#{res.join(", ")})#{block}"
      end

      def parameters(body)
        if body.respond_to?(:to_proc)
          body.to_proc.parameters
        else
          body.method(:call).parameters
        end
      end
    end
  end
end
