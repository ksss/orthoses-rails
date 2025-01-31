begin
  require 'test_helper'
rescue LoadError
end

module EnumTest
  LOADER1 = ->(){
    class User1 < ActiveRecord::Base
      enum :array, [ :array_active, :array_archived ]
      enum :map, { map_active: "active", map_archived: "archived" }
      enum :pref, [ :active, :archived ], prefix: true
      enum :suff, [ :active, :archived ], suffix: true
      enum :escape, [:"a-b-c", :"e_[]_f"]
    end
  }

  LOADER2 = ->(){
    class User2 < ActiveRecord::Base
      enum :array, [ :array_active, :array_archived ]
      enum :map, { map_active: "active", map_archived: "archived" }
    end
  }

  def test_enum(t)
    store = Orthoses::ActiveRecord::Enum.new(
      Orthoses::Store.new(LOADER1),
      strict: false
    ).call

    actual = store["EnumTest::User1"].to_rbs
    expect = <<~RBS
      class EnumTest::User1 < ::ActiveRecord::Base
        include EnumTest::User1::ActiveRecord_Enum_EnumMethods
        def self.arrays: () -> ActiveSupport::HashWithIndifferentAccess[String, Integer]
        def array: () -> String
        def array=: (Symbol | String) -> void
                  | (Integer) -> void
        def self.maps: () -> ActiveSupport::HashWithIndifferentAccess[String, String]
        def map: () -> String
        def map=: (Symbol | String) -> void
                | (String) -> void
        def self.prefs: () -> ActiveSupport::HashWithIndifferentAccess[String, Integer]
        def pref: () -> String
        def pref=: (Symbol | String) -> void
                 | (Integer) -> void
        def self.suffs: () -> ActiveSupport::HashWithIndifferentAccess[String, Integer]
        def suff: () -> String
        def suff=: (Symbol | String) -> void
                 | (Integer) -> void
        def self.escapes: () -> ActiveSupport::HashWithIndifferentAccess[String, Integer]
        def escape: () -> String
        def escape=: (Symbol | String) -> void
                   | (Integer) -> void
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

    store = Orthoses::ActiveRecord::Enum.new(
      Orthoses::Store.new(LOADER2),
      strict: true
    ).call

    actual = store["EnumTest::User2"].to_rbs
    expect = <<~RBS
      class EnumTest::User2 < ::ActiveRecord::Base
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

    actual = store["EnumTest::User2::ActiveRecord_Enum_EnumMethods"].to_rbs
    expect = <<~RBS
      module EnumTest::User2::ActiveRecord_Enum_EnumMethods
        def array_active?: () -> bool

        def array_active!: () -> bool

        def array_archived?: () -> bool

        def array_archived!: () -> bool

        def map_active?: () -> bool

        def map_active!: () -> bool

        def map_archived?: () -> bool

        def map_archived!: () -> bool
      end
    RBS
    unless expect == actual
      t.error("expect=\n```rbs\n#{expect}```\n, but got \n```rbs\n#{actual}```\n")
    end
  end
end
