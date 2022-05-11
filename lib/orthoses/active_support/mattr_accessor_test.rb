module MattrAccessorTest
  LOADER = ->(){
    module Mod
      mattr_accessor :m_accessor
      mattr_reader :m_reader_no_args
      mattr_reader :m_reader_instance_reader_false, instance_reader: false
      mattr_writer :m_writer_no_args
      mattr_writer :m_writer_instance_reader_false, instance_writer: false
    end
  }

  def test_mattr_accessor(t)
    store = Orthoses::ActiveSupport::MattrAccessor.new(
      Orthoses::Store.new(LOADER)
    ).call
    expect = <<~RBS
      module MattrAccessorTest::Mod
        def self.m_accessor: () -> untyped

        def m_accessor: () -> untyped

        def self.m_reader_no_args: () -> untyped

        def m_reader_no_args: () -> untyped

        def self.m_reader_instance_reader_false: () -> untyped

        def self.m_accessor=: (untyped val) -> untyped

        def m_accessor=: (untyped val) -> untyped

        def self.m_writer_no_args=: (untyped val) -> untyped

        def m_writer_no_args=: (untyped val) -> untyped

        def self.m_writer_instance_reader_false=: (untyped val) -> untyped
      end
    RBS
    actual = store["MattrAccessorTest::Mod"].to_rbs
    unless expect == actual
      t.error("expect=\n```rbs\n#{expect}```\n, but got \n```rbs\n#{actual}```\n")
    end
  end
end
