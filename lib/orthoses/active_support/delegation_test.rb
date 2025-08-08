begin
  require 'test_helper'
rescue LoadError
end

module DelegationTest
  LOADER = -> {
    class Foo
      delegate :name, to: Object
      delegate :nothing, to: Object
      delegate :prev, to: :to_bar, private: true
      delegate :ref_no_type, to: :no_type
      delegate :skip, to: :nothing
      delegate :nothing, to: :string
      delegate :empty?, to: :string
      delegate :to_int, to: "@single_var"
      delegate :to_f, to: "@@single_cvar"
      delegate :to_r, to: :SINGLE_CONST
      delegate :ord, to: :single_alias
      delegate :even?, to: :defined
      delegate :from_bar, to: :to_bar
      delegate :ref_untyped_function, to: :untyped_function
    end
  }
  def test_delegate(t)
    buffer, directives, decls = RBS::Parser.parse_signature(<<~RBS)
      module DelegationTest
        class Foo
          def defined: () -> ::Integer
        end
      end
    RBS
    Orthoses::Utils.rbs_environment.add_signature(buffer: buffer, directives: directives, decls: decls)
    store = Orthoses::ActiveSupport::Delegation.new(
      Orthoses::Tap.new(Orthoses::Store.new(LOADER)) { |store|
        store["DelegationTest::Foo"].header = "class Foo"
        store["DelegationTest::Foo"] << "def no_type: () -> untyped"
        store["DelegationTest::Foo"] << "def string: () -> String"
        store["DelegationTest::Foo"] << "@single_var: Integer"
        store["DelegationTest::Foo"] << "@@single_cvar: Integer"
        store["DelegationTest::Foo"] << "alias single_alias string"
        store["DelegationTest::Foo"] << "SINGLE_CONST: Integer"
        store["DelegationTest::Foo"] << "def to_bar: () -> DelegationTest::Bar"
        store["DelegationTest::Foo"] << "def untyped_function: (?) -> untyped"
        store["DelegationTest::Bar"].header = "class Bar"
        store["DelegationTest::Bar"] << "def from_bar: () -> DelegationTest::Bar"
        store["DelegationTest::Bar"] << "private def priv: () -> void"
      }
    ).call

    actual = store["DelegationTest::Foo"].tap { |c|
      # remove comment
      c.body.delete_if {|line| line.start_with?('#') }
    }.to_rbs
    expect = <<~RBS
      class ::DelegationTest::Foo
        def no_type: () -> untyped
        def string: () -> String
        @single_var: Integer
        @@single_cvar: Integer
        alias single_alias string
        SINGLE_CONST: Integer
        def to_bar: () -> DelegationTest::Bar
        def untyped_function: (?) -> untyped
        def name: () -> ::String
        def ref_no_type: (?) -> untyped
        def skip: (?) -> untyped
        def empty?: () -> bool
        def to_int: () -> ::Integer
        def to_f: () -> ::Float
        def to_r: () -> ::Rational
        def ord: () -> ::Integer
        def even?: () -> bool
        def from_bar: () -> DelegationTest::Bar
        def ref_untyped_function: (?) -> untyped
      end
    RBS
    unless expect == actual
      t.error("expect=\n```rbs\n#{expect}```\n, but got \n```rbs\n#{actual}```\n")
    end
  end
end
