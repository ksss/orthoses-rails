# frozen_string_literal: true

begin
  require 'test_helper'
rescue LoadError
end
require_relative '../../../test/fake_schema'

module PersistenceTest
  LOADER = ->(){
    class User < ActiveRecord::Base
      alias_attribute :full_name, :name
    end

    class ChildUser < User
    end
  }

  def test_class_methods(t)
    store = Orthoses::ActiveRecord::Persistence.new(
      Orthoses::Store.new(LOADER)
    ).call

    expect = <<~RBS
      class PersistenceTest::User < ::ActiveRecord::Base
        extend PersistenceTest::User::ActiveRecord_Persistence_ClassMethods
      end
    RBS
    actual = store["PersistenceTest::User"].to_rbs
    unless expect == actual
      t.error("expect=\n```rbs\n#{expect}```\n, but got \n```rbs\n#{actual}```\n")
    end

    expect = <<~RBS
      module PersistenceTest::User::ActiveRecord_Persistence_ClassMethods
        def create: (?id: ::Integer, ?name: ::String, ?confirmed: bool?, ?full_name: ::String, **untyped) ?{ (PersistenceTest::User) -> void } -> PersistenceTest::User
                  | (::Array[Hash[Symbol, untyped]]) ?{ (PersistenceTest::User) -> void } -> ::Array[PersistenceTest::User]

        def create!: (?id: ::Integer, ?name: ::String, ?confirmed: bool?, ?full_name: ::String, **untyped) ?{ (PersistenceTest::User) -> void } -> PersistenceTest::User
                   | (::Array[Hash[Symbol, untyped]]) ?{ (PersistenceTest::User) -> void } -> ::Array[PersistenceTest::User]

        def build: (?id: ::Integer, ?name: ::String, ?confirmed: bool?, ?full_name: ::String, **untyped) ?{ (PersistenceTest::User) -> void } -> PersistenceTest::User
                 | (::Array[Hash[Symbol, untyped]]) ?{ (PersistenceTest::User) -> void } -> ::Array[PersistenceTest::User]
      end
    RBS
    actual = store["PersistenceTest::User::ActiveRecord_Persistence_ClassMethods"].to_rbs
    unless expect == actual
      t.error("expect=\n```rbs\n#{expect}```\n, but got \n```rbs\n#{actual}```\n")
    end

    expect = <<~RBS
      class PersistenceTest::ChildUser < ::PersistenceTest::User
        extend PersistenceTest::ChildUser::ActiveRecord_Persistence_ClassMethods
      end
    RBS
    actual = store["PersistenceTest::ChildUser"].to_rbs
    unless expect == actual
      t.error("expect=\n```rbs\n#{expect}```\n, but got \n```rbs\n#{actual}```\n")
    end

    expect = <<~RBS
      module PersistenceTest::ChildUser::ActiveRecord_Persistence_ClassMethods
        def create: (?id: ::Integer, ?name: ::String, ?confirmed: bool?, ?full_name: ::String, **untyped) ?{ (PersistenceTest::ChildUser) -> void } -> PersistenceTest::ChildUser
                  | (::Array[Hash[Symbol, untyped]]) ?{ (PersistenceTest::ChildUser) -> void } -> ::Array[PersistenceTest::ChildUser]

        def create!: (?id: ::Integer, ?name: ::String, ?confirmed: bool?, ?full_name: ::String, **untyped) ?{ (PersistenceTest::ChildUser) -> void } -> PersistenceTest::ChildUser
                   | (::Array[Hash[Symbol, untyped]]) ?{ (PersistenceTest::ChildUser) -> void } -> ::Array[PersistenceTest::ChildUser]

        def build: (?id: ::Integer, ?name: ::String, ?confirmed: bool?, ?full_name: ::String, **untyped) ?{ (PersistenceTest::ChildUser) -> void } -> PersistenceTest::ChildUser
                 | (::Array[Hash[Symbol, untyped]]) ?{ (PersistenceTest::ChildUser) -> void } -> ::Array[PersistenceTest::ChildUser]
      end
    RBS
    actual = store["PersistenceTest::ChildUser::ActiveRecord_Persistence_ClassMethods"].to_rbs
    unless expect == actual
      t.error("expect=\n```rbs\n#{expect}```\n, but got \n```rbs\n#{actual}```\n")
    end
  end
end
