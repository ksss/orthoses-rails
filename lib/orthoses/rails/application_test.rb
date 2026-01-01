begin
  require 'test_helper'
rescue LoadError
end

module ApplicationTest
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

  def test_generated_relation_methods_by_scope(t)
    store = Orthoses::Rails::Application.new(
      Orthoses::Store.new(LOADER)
    ).call

    actual = store.fetch_values('ApplicationTest::User', 'ApplicationTest::User::GeneratedRelationMethods').map(&:to_rbs).join("\n")
    expect = <<~RBS
      class ApplicationTest::User < ::ActiveRecord::Base
        extend _ActiveRecord_Relation_ClassMethods[ApplicationTest::User, ApplicationTest::User::ActiveRecord_Relation, ::Integer]
        def self.empty: () -> ApplicationTest::User::ActiveRecord_Relation
        def self.params: (untyped a, ?untyped b, *untyped, d: untyped, ?e: untyped, **untyped) -> ApplicationTest::User::ActiveRecord_Relation
        def self.by_status: (?) -> ApplicationTest::User::ActiveRecord_Relation
        extend ApplicationTest::User::ActiveRecord_Persistence_ClassMethods
        include ApplicationTest::User::GeneratedAssociationMethods
        include ApplicationTest::User::GeneratedAttributeMethods
      end

      module ApplicationTest::User::GeneratedRelationMethods
        def params: (untyped a, ?untyped b, *untyped, d: untyped, ?e: untyped, **untyped) -> ApplicationTest::User::ActiveRecord_Relation

        def by_status: (?) -> ApplicationTest::User::ActiveRecord_Relation

        def empty: () -> ApplicationTest::User::ActiveRecord_Relation
      end
    RBS
    unless expect == actual
      t.error("expect=\n```rbs\n#{expect}```\n, but got \n```rbs\n#{actual}```\n")
    end
  end

  def test_check_typo_only(t)
    Orthoses::Rails::Application.new(
      Orthoses::Store.new(->{})
    ).call
  end
end
