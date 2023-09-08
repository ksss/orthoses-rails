begin
  require 'test_helper'
rescue LoadError
end

module EnumTest
  LOADER1 = ->(){
    class User1 < ActiveRecord::Base
      enum array: [ :array_active, :array_archived ]
      enum map: { map_active: "active", map_archived: "archived" }
      enum pref: [ :active, :archived ], _prefix: true
      enum suff: [ :active, :archived ], _suffix: true
      enum escape: [:"a-b-c", :"e_[]_f"]
    end
  }
  def test_enum(t)
    store = Orthoses::ActiveRecord::Enum.new(
      Orthoses::Store.new(LOADER1)
    ).call

    actual = store["EnumTest::User1"].to_rbs
    expect = <<~RBS
      class EnumTest::User1 < ::ActiveRecord::Base
        include EnumTest::User1::ActiveRecord_Enum_EnumMethods
        def self.arrays: () -> ActiveSupport::HashWithIndifferentAccess[String, Integer]
        def array: () -> ("array_active" | "array_archived")
        def array=: (:array_active | :array_archived) -> void
                  | ("array_active" | "array_archived") -> void
                  | (0 | 1) -> void
        def self.maps: () -> ActiveSupport::HashWithIndifferentAccess[String, String]
        def map: () -> ("map_active" | "map_archived")
        def map=: (:map_active | :map_archived) -> void
                | ("map_active" | "map_archived") -> void
                | ("active" | "archived") -> void
        def self.prefs: () -> ActiveSupport::HashWithIndifferentAccess[String, Integer]
        def pref: () -> ("active" | "archived")
        def pref=: (:active | :archived) -> void
                 | ("active" | "archived") -> void
                 | (0 | 1) -> void
        def self.suffs: () -> ActiveSupport::HashWithIndifferentAccess[String, Integer]
        def suff: () -> ("active" | "archived")
        def suff=: (:active | :archived) -> void
                 | ("active" | "archived") -> void
                 | (0 | 1) -> void
        def self.escapes: () -> ActiveSupport::HashWithIndifferentAccess[String, Integer]
        def escape: () -> ("a-b-c" | "e_[]_f")
        def escape=: (Symbol) -> void
                   | ("a-b-c" | "e_[]_f") -> void
                   | (0 | 1) -> void
      end
    RBS
    unless expect == actual
      t.error("expect=\n```rbs\n#{expect}```\n, but got \n```rbs\n#{actual}```\n")
    end

    actual = store["EnumTest::User1::ActiveRecord_Enum_EnumMethods"].to_rbs
    expect = <<~RBS
      module EnumTest::User1::ActiveRecord_Enum_EnumMethods
        def array_active?: () -> bool

        def array_active!: () -> bool

        def array_archived?: () -> bool

        def array_archived!: () -> bool

        def map_active?: () -> bool

        def map_active!: () -> bool

        def map_archived?: () -> bool

        def map_archived!: () -> bool

        def pref_active?: () -> bool

        def pref_active!: () -> bool

        def pref_archived?: () -> bool

        def pref_archived!: () -> bool

        def active_suff?: () -> bool

        def active_suff!: () -> bool

        def archived_suff?: () -> bool

        def archived_suff!: () -> bool

        def `a-b-c?`: () -> bool

        def `a-b-c!`: () -> bool

        def a_b_c?: () -> bool

        def a_b_c!: () -> bool

        def `e_[]_f?`: () -> bool

        def `e_[]_f!`: () -> bool

        def e___f?: () -> bool

        def e___f!: () -> bool
      end
    RBS
    unless expect == actual
      t.error("expect=\n```rbs\n#{expect}```\n, but got \n```rbs\n#{actual}```\n")
    end
  end

  LOADER2 = ->(){
    class User2 < ActiveRecord::Base
      enum array: [ :array_active, :array_archived ]
      enum map: { map_active: "active", map_archived: "archived" }, _scopes: false
    end
  }
  def test_enum_with_scope(t)
    store = Orthoses::ActiveRecord::Enum.new(
      Orthoses::ActiveRecord::Scope.new(
        Orthoses::Store.new(LOADER2)
      )
    ).call

    actual = store["EnumTest::User2"].to_rbs
    expect = <<~RBS
      class EnumTest::User2 < ::ActiveRecord::Base
        def self.array_active: () -> EnumTest::User2::ActiveRecord_Relation
        def self.not_array_active: () -> EnumTest::User2::ActiveRecord_Relation
        def self.array_archived: () -> EnumTest::User2::ActiveRecord_Relation
        def self.not_array_archived: () -> EnumTest::User2::ActiveRecord_Relation
        include EnumTest::User2::ActiveRecord_Enum_EnumMethods
        def self.arrays: () -> ActiveSupport::HashWithIndifferentAccess[String, Integer]
        def array: () -> ("array_active" | "array_archived")
        def array=: (:array_active | :array_archived) -> void
                  | ("array_active" | "array_archived") -> void
                  | (0 | 1) -> void
        def self.maps: () -> ActiveSupport::HashWithIndifferentAccess[String, String]
        def map: () -> ("map_active" | "map_archived")
        def map=: (:map_active | :map_archived) -> void
                | ("map_active" | "map_archived") -> void
                | ("active" | "archived") -> void
      end
    RBS
    unless expect == actual
      t.error("expect=\n```rbs\n#{expect}```\n, but got \n```rbs\n#{actual}```\n")
    end

    actual = store["EnumTest::User2::GeneratedRelationMethods"].to_rbs
    expect = <<~RBS
      module EnumTest::User2::GeneratedRelationMethods
        def array_active: () -> EnumTest::User2::ActiveRecord_Relation

        def not_array_active: () -> EnumTest::User2::ActiveRecord_Relation

        def array_archived: () -> EnumTest::User2::ActiveRecord_Relation

        def not_array_archived: () -> EnumTest::User2::ActiveRecord_Relation
      end
    RBS
    unless expect == actual
      t.error("expect=\n```rbs\n#{expect}```\n, but got \n```rbs\n#{actual}```\n")
    end
  end

  if ActiveRecord::VERSION::MAJOR >= 7
    LOADER3 = ->{
      class User3 < ActiveRecord::Base
        enum :array, [ :array_active, :array_archived ]
        enum :map, map_active: "active", map_archived: "archived"
      end
    }
    def test_rails_7_style(t)
      store = Orthoses::ActiveRecord::Enum.new(
        Orthoses::Store.new(LOADER3)
      ).call

      actual = store["EnumTest::User3"].to_rbs
      expect = <<~RBS
        class EnumTest::User3 < ::ActiveRecord::Base
          include EnumTest::User3::ActiveRecord_Enum_EnumMethods
          def self.arrays: () -> ActiveSupport::HashWithIndifferentAccess[String, Integer]
          def array: () -> ("array_active" | "array_archived")
          def array=: (:array_active | :array_archived) -> void
                    | ("array_active" | "array_archived") -> void
                    | (0 | 1) -> void
          def self.maps: () -> ActiveSupport::HashWithIndifferentAccess[String, String]
          def map: () -> ("map_active" | "map_archived")
          def map=: (:map_active | :map_archived) -> void
                  | ("map_active" | "map_archived") -> void
                  | ("active" | "archived") -> void
        end
      RBS
      unless expect == actual
        t.error("expect=\n```rbs\n#{expect}```\n, but got \n```rbs\n#{actual}```\n")
      end
    end
  end
end
