# frozen_string_literal: true

require_relative '../../../test/fake_schema'

module RelationTest
  LOADER = ->(){
    class User < ActiveRecord::Base
    end
  }

  def test_relation(t)
    store = Orthoses::ActiveRecord::Relation.new(
      Orthoses::Store.new(LOADER)
    ).call

    expected_keys = [
      "RelationTest::User",
      "RelationTest::User::ActiveRecord_Associations_CollectionProxy",
      "RelationTest::User::ActiveRecord_Relation",
      "RelationTest::User::GeneratedRelationMethods"
    ]
    unless store.keys.filter{_1.start_with?("RelationTest")}.sort == expected_keys.sort
      t.error("found unexpected keys #{store.keys - expected_keys}")
    end

    expect = <<~RBS
      class RelationTest::User::ActiveRecord_Relation < ::ActiveRecord::Relation
        include RelationTest::User::GeneratedRelationMethods
        include _ActiveRecord_Relation[RelationTest::User, untyped]
        include Enumerable[RelationTest::User]
      end
    RBS
    actual = store["RelationTest::User::ActiveRecord_Relation"].to_rbs
    unless expect == actual
      t.error("expect=\n```rbs\n#{expect}```\n, but got \n```rbs\n#{actual}```\n")
    end

    expect = <<~RBS
      class RelationTest::User::ActiveRecord_Associations_CollectionProxy < ::ActiveRecord::Associations::CollectionProxy
        include _ActiveRecord_Relation[RelationTest::User, untyped]
      end
    RBS
    actual = store["RelationTest::User::ActiveRecord_Associations_CollectionProxy"].to_rbs
    unless expect == actual
      t.error("expect=\n```rbs\n#{expect}```\n, but got \n```rbs\n#{actual}```\n")
    end

    expect = <<~RBS
      class RelationTest::User < ::ActiveRecord::Base
        extend _ActiveRecord_Relation_ClassMethods[RelationTest::User, RelationTest::User::ActiveRecord_Relation, untyped]
      end
    RBS
    actual = store["RelationTest::User"].to_rbs
    unless expect == actual
      t.error("expect=\n```rbs\n#{expect}```\n, but got \n```rbs\n#{actual}```\n")
    end
  end
end
