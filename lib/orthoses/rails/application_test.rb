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

    user_signature = store.fetch('ApplicationTest::User').to_rbs

    /(def self\.empty:.*$)/.match(user_signature) => [actual_user_empty_signature]
    expect_user_empty_signature = 'def self.empty: () -> ApplicationTest::User::ActiveRecord_Relation'
    unless expect_user_empty_signature == actual_user_empty_signature
      t.error("expect=\n```rbs\n#{expect_user_empty_signature}```\n, but got \n```rbs\n#{actual_user_empty_signature}```\n")
    end

    /(def self\.params:.*$)/.match(user_signature) => [actual_user_params_signature]
    expect_user_params_signature = 'def self.params: (untyped a, ?untyped b, *untyped, d: untyped, ?e: untyped, **untyped) -> ApplicationTest::User::ActiveRecord_Relation'
    unless expect_user_params_signature == actual_user_params_signature
      t.error("expect=\n```rbs\n#{expect_user_params_signature}```\n, but got \n```rbs\n#{actual_user_params_signature}```\n")
    end

    /(def self\.by_status:.*$)/.match(user_signature) => [actual_user_by_status_signature]
    expect_user_by_status_signature = 'def self.by_status: (?) -> ApplicationTest::User::ActiveRecord_Relation'
    unless expect_user_by_status_signature == actual_user_by_status_signature
      t.error("expect=\n```rbs\n#{expect_user_by_status_signature}```\n, but got \n```rbs\n#{actual_user_by_status_signature}```\n")
    end

    generated_relation_methods_signature = store.fetch('ApplicationTest::User::GeneratedRelationMethods').to_rbs

    /(def empty:.*$)/.match(generated_relation_methods_signature) => [actual_generated_relation_methods_empty_signature]
    expect_generated_relation_methods_empty_signature = 'def empty: () -> ApplicationTest::User::ActiveRecord_Relation'
    unless expect_generated_relation_methods_empty_signature == actual_generated_relation_methods_empty_signature
      t.error("expect=\n```rbs\n#{expect_generated_relation_methods_empty_signature}```\n, but got \n```rbs\n#{actual_generated_relation_methods_empty_signature}```\n")
    end

    /(def params:.*$)/.match(generated_relation_methods_signature) => [actual_generated_relation_methods_params_signature]
    expect_generated_relation_methods_params_signature = 'def params: (untyped a, ?untyped b, *untyped, d: untyped, ?e: untyped, **untyped) -> ApplicationTest::User::ActiveRecord_Relation'
    unless expect_generated_relation_methods_params_signature == actual_generated_relation_methods_params_signature
      t.error("expect=\n```rbs\n#{expect_generated_relation_methods_params_signature}```\n, but got \n```rbs\n#{actual_generated_relation_methods_params_signature}```\n")
    end

    /(def by_status:.*$)/.match(generated_relation_methods_signature) => [actual_generated_relation_methods_by_status_signature]
    expect_generated_relation_methods_by_status_signature = 'def by_status: (?) -> ApplicationTest::User::ActiveRecord_Relation'
    unless expect_generated_relation_methods_by_status_signature == actual_generated_relation_methods_by_status_signature
      t.error("expect=\n```rbs\n#{expect_generated_relation_methods_by_status_signature}```\n, but got \n```rbs\n#{actual_generated_relation_methods_by_status_signature}```\n")
    end
  rescue NoMatchingPatternError, KeyError => e
    t.error(e.full_message)
  end

  def test_check_typo_only(t)
    Orthoses::Rails::Application.new(
      Orthoses::Store.new(->{})
    ).call
  end
end
