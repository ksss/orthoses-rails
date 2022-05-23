module ClassAttributeTest
  LOADER = ->(){
    class Foo
      class_attribute :bar
      class_attribute :baz, instance_accessor: false
      class_attribute :qux, instance_predicate: false
    end
  }
  def test_class_attribute(t)
    store = Orthoses::ActiveSupport::ClassAttribute.new(
      Orthoses::Store.new(LOADER)
    ).call

    expect = <<~RBS
      class ClassAttributeTest::Foo
        def self.bar: () -> untyped
        def self.bar?: () -> bool
        def self.bar=: (untyped value) -> untyped
        def bar: () -> untyped
        def bar?: () -> bool
        def bar=: (untyped value) -> untyped
        def self.baz: () -> untyped
        def self.baz?: () -> bool
        def self.baz=: (untyped value) -> untyped
        def self.qux: () -> untyped
        def self.qux=: (untyped value) -> untyped
        def qux: () -> untyped
        def qux=: (untyped value) -> untyped
      end
    RBS
    actual = store["ClassAttributeTest::Foo"].to_rbs
    unless expect == actual
      t.error("expect=\n```rbs\n#{expect}```\n, but got \n```rbs\n#{actual}```\n")
    end
  end
end
