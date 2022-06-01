module DelegationTest
  LOADER = -> {
    class Foo
      delegate :name, to: Object
      delegate :nothing, to: Object
      delegate :ref_no_type, to: :no_type
      delegate :skip, to: :nothing
      delegate :nothing, to: :string
      delegate :gsub, to: :string
      delegate :to_int, to: "@single_var"
      delegate :to_f, to: "@@single_cvar"
      delegate :to_r, to: :SINGLE_CONST
      delegate :ord, to: :single_alias
    end
  }
  def test_delegate(t)
    store = Orthoses::ActiveSupport::Delegation.new(
      Orthoses::Tap.new(Orthoses::Store.new(LOADER)) { |store|
        store["DelegationTest::Foo"].header = "class Foo"
        store["DelegationTest::Foo"] << "def no_type: () -> untyped"
        store["DelegationTest::Foo"] << "def string: () -> String"
        store["DelegationTest::Foo"] << "@single_var: Integer"
        store["DelegationTest::Foo"] << "@@single_cvar: Integer"
        store["DelegationTest::Foo"] << "alias single_alias string"
        store["DelegationTest::Foo"] << "SINGLE_CONST: Integer"
      }
    ).call

    actual = store["DelegationTest::Foo"].tap { |c|
      # remove comment
      c.body.delete_if {|line| line.start_with?('#') }
    }.to_rbs
    expect = <<~RBS
      class Foo
        def no_type: () -> untyped
        def string: () -> String
        @single_var: Integer
        @@single_cvar: Integer
        alias single_alias string
        SINGLE_CONST: Integer
        def name: () -> ::String?
        def ref_no_type: (*untyped, **untyped) -> untyped
        def gsub: (::Regexp | ::string pattern, ::string replacement) -> ::String
                | (::Regexp | ::string pattern, ::Hash[::String, ::String] hash) -> ::String
                | (::Regexp | ::string pattern) { (::String match) -> ::_ToS } -> ::String
                | (::Regexp | ::string pattern) -> ::Enumerator[::String, self]
        def to_int: () -> ::Integer
        def to_f: () -> ::Float
        def to_r: () -> ::Rational
        def ord: () -> ::Integer
      end
    RBS
    unless expect == actual
      t.error("expect=\n```rbs\n#{expect}```\n, but got \n```rbs\n#{actual}```\n")
    end
  end
end
