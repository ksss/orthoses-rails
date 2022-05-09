# frozen_string_literal: true

module Orthoses
  module ActiveRecord
    class HasMany
      def initialize(loader)
        @loader = loader
      end

      def call
        @loader.call.tap do |store|
          ::ActiveRecord::Base.descendants.each do |base|
            next if base.abstract_class?

            generated_association_methods = "#{base}::GeneratedAssociationMethods"
            collection_proxy = "#{base}::ActiveRecord_Associations_CollectionProxy"

            lines = base.reflect_on_all_associations(:has_many).flat_map do |ref|
              singular_name = ref.name.to_s.singularize

              [
                "def #{ref.name}: () -> #{collection_proxy}",
                "def #{ref.name}=: (#{collection_proxy} | Array[#{ref.klass}]) -> (#{collection_proxy} | Array[#{ref.klass}])",
                "def #{singular_name}_ids: () -> Array[Integer]",
                "def #{singular_name}_ids=: (Array[Integer]) -> Array[Integer]",
              ]
            end

            store["module #{generated_association_methods}"].concat(lines)

            code = "include #{generated_association_methods}"
            store[base.to_s] << code
          end
        end
      end
    end
  end
end
