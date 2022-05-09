# frozen_string_literal: true

module Orthoses
  module ActiveRecord
    class BelongsTo
      def initialize(loader)
        @loader = loader
      end

      def call
        @loader.call.tap do |store|
          ::ActiveRecord::Base.descendants.each do |base|
            next if base.abstract_class?

            lines = base.reflect_on_all_associations(:belongs_to).flat_map do |ref|
              # FIXME: Can I get list of class for polymorphic?
              type = ref.polymorphic? ? 'untyped' : ref.klass.to_s
              opt = "#{type}?"

              [
                "def #{ref.name}: () -> #{opt}",
                "def #{ref.name}=: (#{opt}) -> #{opt}",
                "def reload_#{ref.name}: () -> #{opt}",
              ].tap do |ary|
                if !ref.polymorphic?
                  ary << "def build_#{ref.name}: (?untyped attributes) ?{ (#{type}) -> void } -> #{type}"
                  ary << "def create_#{ref.name}: (?untyped attributes) ?{ (#{type}) -> void } -> #{type}"
                  ary << "def create_#{ref.name}!: (?untyped attributes) ?{ (#{type}) -> void } -> #{type}"
                end
              end
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
