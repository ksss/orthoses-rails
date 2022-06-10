module ConfigurableTest
  LOADER = -> {
    class Foo
      include ActiveSupport::Configurable
      config_accessor :foo
      config_accessor :bar, instance_accessor: false
    end
  }
  def test_config_accessor(t)
    store = Orthoses::ActiveSupport::Configurable.new(
      Orthoses::Store.new(LOADER)
    ).call
    actual = store["ConfigurableTest::Foo"].to_rbs
    expect = <<~RBS
      class ConfigurableTest::Foo
        def self.foo: () -> untyped
        def self.foo=: (untyped value) -> untyped
        def foo: () -> untyped
        def foo=: (untyped value) -> untyped
        def self.bar: () -> untyped
        def self.bar=: (untyped value) -> untyped
      end
    RBS
    unless expect == actual
      t.error("expect=\n```rbs\n#{expect}```\n, but got \n```rbs\n#{actual}```\n")
    end
  end
end
