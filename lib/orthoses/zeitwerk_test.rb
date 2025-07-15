begin
  require 'test_helper'
rescue LoadError
end

module ZeitwerkTest
  LOADER = ->(){
    cref = ::Zeitwerk::Cref.new(ZeitwerkTest, :A)
    cref.set(Module.new)
  }

  def test_zeitwerk(t)
    store = Orthoses::Zeitwerk.new(
      Orthoses::Store.new(LOADER)
    ).call
    content = store["ZeitwerkTest::A"]
    unless content.to_rbs == "module ZeitwerkTest::A\nend\n"
      t.error("Expected ZeitwerkTest::A to be a module")
    end
  end
end
