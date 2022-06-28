module ScopeTest
  LOADER = ->(){
    class User < ActiveRecord::Base
      scope :empty, -> () { }
      scope :params, -> (a, b = 1, *c, d:, e: 2, **f) { }
    end
  }

  def test_scope(t)
    store = Orthoses::ActiveRecord::Scope.new(
      Orthoses::Store.new(LOADER)
    ).call

    actual = store.map { |_, content| content.to_rbs }.join("\n")
    expect = <<~RBS
      class ScopeTest::User < ::ActiveRecord::Base
        def self.empty: () -> ScopeTest::User::ActiveRecord_Relation
        def self.params: (untyped a, ?untyped b, *untyped c, d: untyped, ?e: untyped, **untyped f) -> ScopeTest::User::ActiveRecord_Relation
      end

      module ScopeTest::User::GeneratedRelationMethods
        def empty: () -> ScopeTest::User::ActiveRecord_Relation

        def params: (untyped a, ?untyped b, *untyped c, d: untyped, ?e: untyped, **untyped f) -> ScopeTest::User::ActiveRecord_Relation
      end
    RBS
    unless expect == actual
      t.error("expect=\n```rbs\n#{expect}```\n, but got \n```rbs\n#{actual}```\n")
    end
  end
end
