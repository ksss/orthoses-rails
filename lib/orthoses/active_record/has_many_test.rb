module HasManyTest
  LOADER = ->(){
    class User < ActiveRecord::Base
      has_many :posts
    end

    class Post < ActiveRecord::Base
    end

    Class.new(ActiveRecord::Base) do
      has_many :posts
    end
  }

  def test_hash_many(t)
    store = Orthoses::ActiveRecord::HasMany.new(
      Orthoses::Store.new(LOADER)
    ).call

    expected_keys = [
      "HasManyTest::Post::GeneratedAssociationMethods",
      "HasManyTest::Post",
      "HasManyTest::User::GeneratedAssociationMethods",
      "HasManyTest::User"
    ]
    unless store.keys.filter{_1.start_with?("HasManyTest")}.sort == expected_keys.sort
      t.error("found unexpected keys #{store.keys - expected_keys}")
    end

    expect = <<~RBS
      class HasManyTest::User < ::ActiveRecord::Base
        include HasManyTest::User::GeneratedAssociationMethods
      end
    RBS
    actual = store["HasManyTest::User"].to_rbs
    unless expect == actual
      t.error("expect=\n```rbs\n#{expect}```\n, but got \n```rbs\n#{actual}```\n")
    end

    expect = <<~RBS
      module HasManyTest::User::GeneratedAssociationMethods
        def posts: () -> HasManyTest::User::ActiveRecord_Associations_CollectionProxy

        def posts=: (HasManyTest::User::ActiveRecord_Associations_CollectionProxy | Array[HasManyTest::Post]) -> (HasManyTest::User::ActiveRecord_Associations_CollectionProxy | Array[HasManyTest::Post])

        def post_ids: () -> Array[Integer]

        def post_ids=: (Array[Integer]) -> Array[Integer]
      end
    RBS
    actual = store["HasManyTest::User::GeneratedAssociationMethods"].to_rbs
    unless expect == actual
      t.error("expect=\n```rbs\n#{expect}```\n, but got \n```rbs\n#{actual}```\n")
    end
  end
end
