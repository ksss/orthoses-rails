# frozen_string_literal: true

module Orthoses
  module ActiveStorage
    module Attached
      # <= 6.0
      #   def has_one_attached(name, dependent: :purge_later)
      # >= 6.1
      #   def has_one_attached(name, dependent: :purge_later, service: nil, strict_loading: false)
      class Model
        def initialize(loader)
          @loader = loader
        end

        def call
          store = @loader.call

          ::ActiveRecord::Base.descendants.each do |base|
            next if base.abstract_class?
            next if base.reflect_on_all_attachments.empty?

            base_name = Utils.module_name(base) or next
            base.reflect_on_all_attachments.each do |reflection|
              type =
                case reflection
                when ::ActiveStorage::Reflection::HasOneAttachedReflection
                  "ActiveStorage::Attached::One"
                when ::ActiveStorage::Reflection::HasManyAttachedReflection
                  "ActiveStorage::Attached::Many"
                else
                  "untyped"
                end
              name = reflection.name

              store[base_name].tap do |content|
                content << "def #{name}: () -> #{type}"
                content << "def #{name}=: (untyped attachable) -> untyped"
              end
            end
          end

          store
        end
      end
    end
  end
end
