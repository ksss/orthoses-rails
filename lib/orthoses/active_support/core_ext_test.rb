begin
  require 'test_helper'
rescue LoadError
end

module CoreExtTest
  LOADER_CONCERNING = -> {
    concerning :Topic do
    end
  }
  def test_concerning(t)
    store = Orthoses::ActiveSupport::CoreExt.new(
      Orthoses::Store.new(LOADER_CONCERNING),
    ).call

    expect = <<~RBS
      module CoreExtTest::Topic
      end
    RBS
    actual = store["CoreExtTest::Topic"].to_rbs
    unless expect == actual
      t.error("expect=\n```rbs\n#{expect}```\n, but got \n```rbs\n#{actual}```\n")
    end
  end
end
