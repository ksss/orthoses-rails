# frozen_string_literal: true

module Orthoses
  module ActiveRecord
    class Relation
      def initialize(loader, strict: false)
        @loader = loader
        @strict = strict
      end

      def call
        @loader.call.tap do |store|
          ::ActiveRecord::Base.descendants.each do |klass|
            next if klass.abstract_class?

            primary_key = fetch_primary_key(klass)

            model_name = Utils.module_name(klass) or next
            class_specific_relation = "#{model_name}::ActiveRecord_Relation"
            class_specific_proxy = "#{model_name}::ActiveRecord_Associations_CollectionProxy"
            class_specific_generated_relation_methods = "#{model_name}::GeneratedRelationMethods"

            # Expressing delegation.
            store[class_specific_generated_relation_methods].tap do |c|
              klass.singleton_methods(false).each do |singleton_method|
                c << "def #{singleton_method}: (?) -> untyped"
              end
              if @strict
                (klass.singleton_class.included_modules - ::ActiveRecord::Relation.included_modules).each do |mod|
                  mname = Utils.module_name(mod) or next
                  store[mname].header = "module #{mname}"
                  c << "include #{mname}"
                end
              end
            end

            store[class_specific_relation].tap do |c|
              c.header = "class #{class_specific_relation} < ::ActiveRecord::Relation"
              c << "include #{class_specific_generated_relation_methods}"
              c << "include _ActiveRecord_Relation[#{model_name}, #{primary_key}]"
              c << "include Enumerable[#{model_name}]"
            end

            store[class_specific_proxy].tap do |c|
              c.header = "class #{class_specific_proxy} < ::ActiveRecord::Associations::CollectionProxy"
              c << "include _ActiveRecord_Relation[#{model_name}, #{primary_key}]"
              c << "include Enumerable[#{model_name}]"
            end

            store[model_name].tap do |c|
              c << "extend _ActiveRecord_Relation_ClassMethods[#{model_name}, #{class_specific_relation}, #{primary_key}]"
            end
          end
        end
      end

      private

      def fetch_primary_key(klass)
        type = klass.type_for_attribute(klass.primary_key).type
        ActiveRecord.sql_type_to_rbs(type)
      rescue ::ActiveRecord::StatementInvalid => e
        Orthoses.logger.warn(e.to_s)
        "untyped"
      end
    end
  end
end

