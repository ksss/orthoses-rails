begin
  require 'test_helper'
rescue LoadError
end

module AliasingTest
  LOADER = ->(){
    class Foo
      alias_attribute :bar, :foo
    end
  }
  def test_alias_attribute(t)
    store = Orthoses::ActiveSupport::Aliasing.new(
      Orthoses::Store.new(LOADER)
    ).call

    expect = <<~RBS
      class AliasingTest::Foo
        def bar: () -> untyped
        def bar?: () -> bool
        def bar=: (untyped) -> untyped
      end
    RBS
    actual = store["AliasingTest::Foo"].to_rbs
    unless expect == actual
      t.error("expect=\n```rbs\n#{expect}```\n, but got \n```rbs\n#{actual}```\n")
    end
  end
end
