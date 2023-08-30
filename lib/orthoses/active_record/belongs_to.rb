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
            base_name = Orthoses::Utils.module_name(base) || next

            lines = base.reflect_on_all_associations(:belongs_to).flat_map do |ref|
              # FIXME: Can I get list of class for polymorphic?
              type = if ref.polymorphic?
                'untyped'
              else
                Orthoses::ActiveRecord.reflection_klass_name(ref) or next
              end
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

            generated_association_methods = "#{base_name}::GeneratedAssociationMethods"

            store[generated_association_methods].tap do |content|
              content.header = "module #{generated_association_methods}"
              content.concat(lines)
            end

            sig = "include #{generated_association_methods}"
            store[base_name] << sig if !store[base_name].body.include?(sig)
          end
        end
      end
    end
  end
end
