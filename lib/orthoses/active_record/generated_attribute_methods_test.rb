# frozen_string_literal: true

require_relative '../../../test/fake_schema'

module GeneratedAttributeMethodsTest
  LOADER = -> () {
    class User < ActiveRecord::Base
    end
    Class.new(ActiveRecord::Base)
  }

  def test_generated_attribute_methods(t)
    store = Orthoses::ActiveRecord::GeneratedAttributeMethods.new(
      Orthoses::Store.new(LOADER)
    ).call

    expected_keys = [
      "GeneratedAttributeMethodsTest::User",
      "GeneratedAttributeMethodsTest::User::AttributeMethods",
      "GeneratedAttributeMethodsTest::User::AttributeMethods::GeneratedAttributeMethods"
    ]
    unless store.keys.filter{_1.start_with?("GeneratedAttributeMethodsTest")}.sort == expected_keys.sort
      t.error("found unexpected keys #{store.keys - expected_keys}")
    end

    expect = <<~RBS
      class GeneratedAttributeMethodsTest::User < ::ActiveRecord::Base
        include GeneratedAttributeMethodsTest::User::AttributeMethods::GeneratedAttributeMethods
      end
    RBS
    actual = store["GeneratedAttributeMethodsTest::User"].to_rbs
    unless expect == actual
      t.error("expect=\n```rbs\n#{expect}```\n, but got \n```rbs\n#{actual}```\n")
    end

    expect = <<~RBS
      module GeneratedAttributeMethodsTest::User::AttributeMethods::GeneratedAttributeMethods
        def id: () -> Integer

        def id=: (Integer) -> Integer

        def id?: () -> bool

        def id_changed?: () -> bool

        def id_change: () -> [ Integer?, Integer? ]

        def id_will_change!: () -> void

        def id_was: () -> Integer?

        def id_previously_changed?: () -> bool

        def id_previous_change: () -> Array[Integer?]?

        def id_previously_was: () -> Integer?

        def id_before_last_save: () -> Integer?

        def id_change_to_be_saved: () -> Array[Integer?]?

        def id_in_database: () -> Integer?

        def saved_change_to_id: () -> Array[Integer?]?

        def saved_change_to_id?: () -> bool

        def will_save_change_to_id?: () -> bool

        def restore_id!: () -> void

        def clear_id_change: () -> void

        def name: () -> String

        def name=: (String) -> String

        def name?: () -> bool

        def name_changed?: () -> bool

        def name_change: () -> [ String?, String? ]

        def name_will_change!: () -> void

        def name_was: () -> String?

        def name_previously_changed?: () -> bool

        def name_previous_change: () -> Array[String?]?

        def name_previously_was: () -> String?

        def name_before_last_save: () -> String?

        def name_change_to_be_saved: () -> Array[String?]?

        def name_in_database: () -> String?

        def saved_change_to_name: () -> Array[String?]?

        def saved_change_to_name?: () -> bool

        def will_save_change_to_name?: () -> bool

        def restore_name!: () -> void

        def clear_name_change: () -> void

        def confirmed: () -> bool?

        def confirmed=: (bool?) -> bool?

        def confirmed?: () -> bool

        def confirmed_changed?: () -> bool

        def confirmed_change: () -> [ bool?, bool? ]

        def confirmed_will_change!: () -> void

        def confirmed_was: () -> bool?

        def confirmed_previously_changed?: () -> bool

        def confirmed_previous_change: () -> Array[bool?]?

        def confirmed_previously_was: () -> bool?

        def confirmed_before_last_save: () -> bool?

        def confirmed_change_to_be_saved: () -> Array[bool?]?

        def confirmed_in_database: () -> bool?

        def saved_change_to_confirmed: () -> Array[bool?]?

        def saved_change_to_confirmed?: () -> bool

        def will_save_change_to_confirmed?: () -> bool

        def restore_confirmed!: () -> void

        def clear_confirmed_change: () -> void
      end
    RBS
    actual = store["GeneratedAttributeMethodsTest::User::AttributeMethods::GeneratedAttributeMethods"].to_rbs
    unless expect == actual
      t.error("expect=\n```rbs\n#{expect}```\n, but got \n```rbs\n#{actual}```\n")
    end
  end
end
