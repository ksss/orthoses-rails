# frozen_string_literal: true

begin
  require 'test_helper'
rescue LoadError
end
require_relative '../../../test/fake_schema'

module GeneratedAttributeMethodsTest
  LOADER = -> () {
    class User < ActiveRecord::Base
      alias_attribute :nickname, :name
    end
    Class.new(ActiveRecord::Base)
  }

  def test_initialize(t)
    Orthoses::ActiveRecord::GeneratedAttributeMethods.new(nil, targets: [ "aaaaa" ])
  rescue ArgumentError => e
    unless e.message == "Unknown target type: [\"aaaaa\"]"
      t.error("expected ArgumentError, but got #{e.message}")
    end
  else
    t.error("expected ArgumentError, but not raised")
  end

  def test_generated_attribute_methods(t)
    store = Orthoses::ActiveRecord::GeneratedAttributeMethods.new(
      Orthoses::Store.new(LOADER),
      targets: [ "attribute?" ]
    ).call

    expected_keys = [
      "GeneratedAttributeMethodsTest::User",
      "GeneratedAttributeMethodsTest::User::GeneratedAttributeMethods"
    ]
    unless store.keys.filter{_1.start_with?("GeneratedAttributeMethodsTest")}.sort == expected_keys.sort
      t.error("found unexpected keys #{store.keys - expected_keys}")
    end

    expect = <<~RBS
      class GeneratedAttributeMethodsTest::User < ::ActiveRecord::Base
        include GeneratedAttributeMethodsTest::User::GeneratedAttributeMethods
      end
    RBS
    actual = store["GeneratedAttributeMethodsTest::User"].to_rbs
    unless expect == actual
      t.error("expect=\n```rbs\n#{expect}```\n, but got \n```rbs\n#{actual}```\n")
    end

    actual = store["GeneratedAttributeMethodsTest::User::GeneratedAttributeMethods"].to_rbs
    expect = <<~RBS
      module GeneratedAttributeMethodsTest::User::GeneratedAttributeMethods
        attr_accessor id: ::Integer

        def id?: () -> bool

        attr_accessor name: ::String

        def name?: () -> bool

        attr_accessor confirmed: bool?

        def confirmed?: () -> bool

        alias nickname name

        alias nickname? name?
      end
    RBS
    unless expect == actual
      t.error("expect=\n```rbs\n#{expect}```\n, but got \n```rbs\n#{actual}```\n")
    end
  end
end
