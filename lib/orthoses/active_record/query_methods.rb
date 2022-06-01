# frozen_string_literal: true

module Orthoses
  module ActiveRecord
    class QueryMethods
      def initialize(loader)
        @loader = loader
      end

      def call
        @loader.call.tap do |store|
          content = store["ActiveRecord::QueryMethods"]

          ::ActiveRecord::Relation::VALUE_METHODS.each do |name|
            method_name, type =
              case name
              when *::ActiveRecord::Relation::MULTI_VALUE_METHODS
                ["#{name}_values", "::Array[untyped]"]
              when *::ActiveRecord::Relation::SINGLE_VALUE_METHODS
                ["#{name}_value", name == :create_with ? "::Hash[untyped, untyped]?" : "untyped"]
              when *::ActiveRecord::Relation::CLAUSE_METHODS
                ["#{name}_clause", name == :from ? "::ActiveRecord::Relation::FromClause" : "::ActiveRecord::Relation::WhereClause"]
              end

            content << "def #{method_name}: () -> #{type}"
            content << "def #{method_name}=: (#{type} value) -> #{type}"
          end
        end
      end
    end
  end
end
