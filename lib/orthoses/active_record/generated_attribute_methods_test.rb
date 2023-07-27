# frozen_string_literal: true

require_relative '../../../test/fake_schema'

module GeneratedAttributeMethodsTest
  LOADER = -> () {
    class User < ActiveRecord::Base
      alias_attribute :nickname, :name
    end
    Class.new(ActiveRecord::Base)
  }

  def test_generated_attribute_methods(t)
    store = Orthoses::ActiveRecord::GeneratedAttributeMethods.new(
      Orthoses::Store.new(LOADER)
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
    [
      "def id: () -> ::Integer",
      "def name: () -> ::String",
      "def confirmed: () -> bool?",
      "alias nickname name"
    ].each do |check|
      unless actual.include?(check)
        t.error("should include `#{check}`. But, not.")
      end
    end
  end
end
