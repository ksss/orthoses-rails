module EnumTest
  LOADER1 = ->(){
    class User1 < ActiveRecord::Base
      enum array: [ :array_active, :array_archived ]
      enum map: { map_active: "active", map_archived: "archived" }
      enum pref: [ :active, :archived ], _prefix: true
      enum suff: [ :active, :archived ], _suffix: true
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
        def self.maps: () -> ActiveSupport::HashWithIndifferentAccess[String, String]
        def self.prefs: () -> ActiveSupport::HashWithIndifferentAccess[String, Integer]
        def self.suffs: () -> ActiveSupport::HashWithIndifferentAccess[String, Integer]
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
        def self.maps: () -> ActiveSupport::HashWithIndifferentAccess[String, String]
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
          def self.maps: () -> ActiveSupport::HashWithIndifferentAccess[String, String]
        end
      RBS
      unless expect == actual
        t.error("expect=\n```rbs\n#{expect}```\n, but got \n```rbs\n#{actual}```\n")
      end
    end
  end
end
