module HasOneTest
  LOADER = ->(){
    class User < ActiveRecord::Base
      has_one :password
    end

    class Password < ActiveRecord::Base
    end

    Class.new(ActiveRecord::Base) do
      has_one :password
    end
  }

  def test_has_one(t)
    store = Orthoses::ActiveRecord::HasOne.new(
      Orthoses::Store.new(LOADER)
    ).call

    expected_keys = [
      "HasOneTest::Password::GeneratedAssociationMethods",
      "HasOneTest::Password",
      "HasOneTest::User::GeneratedAssociationMethods",
      "HasOneTest::User"
    ]
    unless store.keys.sort == expected_keys.sort
      t.error("found unexpected keys #{store.keys - expected_keys}")
    end

    expect = <<~RBS
      class HasOneTest::User < ::ActiveRecord::Base
        include HasOneTest::User::GeneratedAssociationMethods
      end
    RBS
    actual = store["HasOneTest::User"].to_rbs
    unless expect == actual
      t.error("expect=\n```rbs\n#{expect}```\n, but got \n```rbs\n#{actual}```\n")
    end

    expect = <<~RBS
      module HasOneTest::User::GeneratedAssociationMethods
        def password: () -> HasOneTest::Password?

        def password=: (HasOneTest::Password?) -> HasOneTest::Password?

        def build_password: (?untyped attributes) ?{ (HasOneTest::Password) -> void } -> HasOneTest::Password

        def create_password: (?untyped attributes) ?{ (HasOneTest::Password) -> void } -> HasOneTest::Password

        def create_password!: (?untyped attributes) ?{ (HasOneTest::Password) -> void } -> HasOneTest::Password

        def reload_password: () -> HasOneTest::Password?
      end
    RBS
    actual = store["HasOneTest::User::GeneratedAssociationMethods"].to_rbs
    unless expect == actual
      t.error("expect=\n```rbs\n#{expect}```\n, but got \n```rbs\n#{actual}```\n")
    end
  end
end
