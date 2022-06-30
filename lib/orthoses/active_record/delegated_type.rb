# frozen_string_literal: true

module Orthoses
  module ActiveRecord
    # <= 6.0
    #   not implemented
    # >= 6.1
    #   def delegated_type(role, types:, **options)
    class DelegatedType
      def initialize(loader)
        @loader = loader
      end

      def call
        target = begin
          ::ActiveRecord::DelegatedType.instance_method(:delegated_type)
        rescue NameError
          Orthoses.logger.warn("[ActiveRecord::DelegatedType] Skip since `delegated_type' is not implemented")
          return @loader.call
        end
        delegated_type = CallTracer.new
        store = delegated_type.trace(target) do
          @loader.call
        end

        delegated_type.captures.each do |capture|
          base_name = Utils.module_name(capture.method.receiver) or next
          role = capture.argument[:role]
          types = capture.argument[:types]
          options = capture.argument[:options]
          primary_key = options[:primary_key] || "id"

          content = store[base_name]
          content << "def #{role}_class: () -> (#{types.join(' | ')})"
          content << "def #{role}_name: () -> String"
          content << "def build_#{role}: () -> (#{types.join(' | ')})"
          types.each do |type|
            scope_name = type.tableize.gsub("/", "_")
            singular = scope_name.singularize
            content << "def #{singular}?: () -> bool"
            content << "def #{singular}: () -> #{type}?"
            content << "def #{singular}_#{primary_key}: () -> Integer?"
          end
        end

        store
      end
    end
  end
end
