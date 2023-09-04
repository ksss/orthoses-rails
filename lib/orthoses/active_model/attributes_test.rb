begin
  require 'test_helper'
rescue LoadError
end

module AttributesTest
  LOADER = ->{
    class Person
      include ::ActiveModel::Attributes

      attribute :name, :string
      attribute :age, :integer
    end
  }
  def test_attribute(t)
    store = Orthoses::ActiveModel::Attributes.new(
      Orthoses::Store.new(LOADER)
    ).call

    expect = <<~RBS
      class AttributesTest::Person
        include AttributesTest::Person::ActiveModelGeneratedAttributeMethods
      end
    RBS
    actual = store["AttributesTest::Person"].to_rbs
    unless expect == actual
      t.error("expect=\n```rbs\n#{expect}```\n, but got \n```rbs\n#{actual}```\n")
    end

    expect = <<~RBS
      module AttributesTest::Person::ActiveModelGeneratedAttributeMethods
        def name: () -> ::String?

        def name=: (untyped) -> untyped

        def age: () -> ::Integer?

        def age=: (untyped) -> untyped
      end
    RBS
    actual = store["AttributesTest::Person::ActiveModelGeneratedAttributeMethods"].to_rbs
    unless expect == actual
      t.error("expect=\n```rbs\n#{expect}```\n, but got \n```rbs\n#{actual}```\n")
    end
  end
end
