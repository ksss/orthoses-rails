# frozen_string_literal: true

module Orthoses
  module ActiveRecord
    class HasOne
      def initialize(loader)
        @loader = loader
      end

      def call
        @loader.call.tap do |store|
          ::ActiveRecord::Base.descendants.each do |base|
            next if base.abstract_class?

            lines = base.reflect_on_all_associations(:has_one).flat_map do |ref|
              type = ref.klass.to_s
              opt = "#{type}?"

              [
                "def #{ref.name}: () -> #{opt}",
                "def #{ref.name}=: (#{opt}) -> #{opt}",
                "def build_#{ref.name}: (?untyped attributes) ?{ (#{type}) -> void } -> #{type}",
                "def create_#{ref.name}: (?untyped attributes) ?{ (#{type}) -> void } -> #{type}",
                "def create_#{ref.name}!: (?untyped attributes) ?{ (#{type}) -> void } -> #{type}",
                "def reload_#{ref.name}: () -> #{opt}",
              ]
            end

            generated_association_methods = "#{base}::GeneratedAssociationMethods"
            store["module #{generated_association_methods}"].concat(lines)

            code = "include #{generated_association_methods}"
            store[base.to_s] << code
          end
        end
      end
    end
  end
end
