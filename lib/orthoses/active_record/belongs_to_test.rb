module BelongsToTest
  LOADER = ->(){
    class User < ActiveRecord::Base
    end

    class Post < ActiveRecord::Base
      belongs_to :user
    end

    Class.new(ActiveRecord::Base) do
      belongs_to :user
    end
  }

  def test_belongs_to(t)
    store = Orthoses::ActiveRecord::BelongsTo.new(
      Orthoses::Store.new(LOADER)
    ).call

    expected_keys = [
      "BelongsToTest::Post::GeneratedAssociationMethods",
      "BelongsToTest::Post",
      "BelongsToTest::User::GeneratedAssociationMethods",
      "BelongsToTest::User"
    ]
    unless store.keys.sort == expected_keys.sort
      t.error("found unexpected keys #{store.keys - expected_keys}")
    end

    expect = <<~RBS
      class BelongsToTest::Post < ::ActiveRecord::Base
        include BelongsToTest::Post::GeneratedAssociationMethods
      end
    RBS
    actual = store["BelongsToTest::Post"].to_rbs
    unless expect == actual
      t.error("expect=\n```rbs\n#{expect}```\n, but got \n```rbs\n#{actual}```\n")
    end

    expect = <<~RBS
      module BelongsToTest::Post::GeneratedAssociationMethods
        def user: () -> BelongsToTest::User?

        def user=: (BelongsToTest::User?) -> BelongsToTest::User?

        def reload_user: () -> BelongsToTest::User?

        def build_user: (?untyped attributes) ?{ (BelongsToTest::User) -> void } -> BelongsToTest::User

        def create_user: (?untyped attributes) ?{ (BelongsToTest::User) -> void } -> BelongsToTest::User

        def create_user!: (?untyped attributes) ?{ (BelongsToTest::User) -> void } -> BelongsToTest::User
      end
    RBS
    actual = store["BelongsToTest::Post::GeneratedAssociationMethods"].to_rbs
    unless expect == actual
      t.error("expect=\n```rbs\n#{expect}```\n, but got \n```rbs\n#{actual}```\n")
    end
  end
end
