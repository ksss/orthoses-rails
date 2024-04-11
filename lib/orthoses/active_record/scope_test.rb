begin
  require 'test_helper'
rescue LoadError
end

module ScopeTest
  LOADER = ->(){
    class FilterByStatusQuery
      private attr_reader :relation, :options

      def self.call(...)
        new(...).send(:query)
      end

      def initialize(*args)
        @options = args.extract_options!
        @relation = Blog
      end

      private

      def query
        relation.where(status: options[:status])
      end
    end

    class User < ActiveRecord::Base
      scope :empty, -> () { }
      scope :params, -> (a, b = 1, *c, d:, e: 2, **f) { }
      scope :by_status, FilterByStatusQuery
    end
  }

  def test_scope(t)
    store = Orthoses::ActiveRecord::Scope.new(
      Orthoses::Store.new(LOADER)
    ).call

    actual = store.map { |_, content| content.to_rbs }.join("\n")
    expect = <<~RBS
      class ScopeTest::User < ::ActiveRecord::Base
        def self.empty: () -> ScopeTest::User::ActiveRecord_Relation
        def self.params: (untyped a, ?untyped b, *untyped, d: untyped, ?e: untyped, **untyped) -> ScopeTest::User::ActiveRecord_Relation
        def self.by_status: (*untyped, **untyped) { (*untyped) -> untyped } -> ScopeTest::User::ActiveRecord_Relation
      end

      module ScopeTest::User::GeneratedRelationMethods
        def empty: () -> ScopeTest::User::ActiveRecord_Relation

        def params: (untyped a, ?untyped b, *untyped, d: untyped, ?e: untyped, **untyped) -> ScopeTest::User::ActiveRecord_Relation

        def by_status: (*untyped, **untyped) { (*untyped) -> untyped } -> ScopeTest::User::ActiveRecord_Relation
      end
    RBS
    unless expect == actual
      t.error("expect=\n```rbs\n#{expect}```\n, but got \n```rbs\n#{actual}```\n")
    end
  end
end
