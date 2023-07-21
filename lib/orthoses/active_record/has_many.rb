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
            base_name = Utils.module_name(base) || next

            collection_proxy = "#{base_name}::ActiveRecord_Associations_CollectionProxy"

            lines = base.reflect_on_all_associations(:has_many).flat_map do |ref|
              singular_name = ref.name.to_s.singularize
              type =
                begin
                  Utils.module_name(ref.klass)
                rescue NameError => e
                  while e
                    Orthoses.logger.warn(e.message)
                    e = e.cause
                  end
                  next
                end

              [
                "def #{ref.name}: () -> #{collection_proxy}",
                "def #{ref.name}=: (#{collection_proxy} | Array[#{type}]) -> (#{collection_proxy} | Array[#{type}])",
                "def #{singular_name}_ids: () -> Array[Integer]",
                "def #{singular_name}_ids=: (Array[Integer]) -> Array[Integer]",
              ]
            end

            generated_association_methods = "#{base_name}::GeneratedAssociationMethods"
            store[generated_association_methods].header = "module #{generated_association_methods}"
            store[generated_association_methods].concat(lines)

            sig = "include #{generated_association_methods}"
            store[base_name] << sig if !store[base_name].body.include?(sig)
          end
        end
      end
    end
  end
end
