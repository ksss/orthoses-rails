module ConcernTest
  LOADER = ->(){
    module Mod
      extend ActiveSupport::Concern
    end
    Module.new do
      extend ActiveSupport::Concern
    end
  }

  def test_concern(t)
    store = Orthoses::ActiveSupport::Concern.new(
      Orthoses::Store.new(LOADER)
    ).call

    unless store.length == 1
      t.error("found unexpected keys #{store.keys - ["ConcernTest::Mod"]}")
    end

    expect = <<~RBS
      module ConcernTest::Mod
        extend ActiveSupport::Concern
      end
    RBS
    actual = store["ConcernTest::Mod"].to_rbs
    unless expect == actual
      t.error("expect=\n```rbs\n#{expect}```\n, but got \n```rbs\n#{actual}```\n")
    end
  end
end
