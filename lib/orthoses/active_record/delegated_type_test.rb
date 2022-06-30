module DelegatedTypeTest
  LOADER1 = ->(){
    class Entry < ActiveRecord::Base
      delegated_type :entryable, types: %w[ Message Comment ], dependent: :destroy
    end
  }
  def test_delegated_type(t)
    if ::ActiveRecord.version < Gem::Version.new("6.1")
      t.skip("delegate_type is not implemented in #{::ActiveRecord.version}")
    end

    store = Orthoses::ActiveRecord::DelegatedType.new(
      Orthoses::Store.new(LOADER1)
    ).call

    actual = store["DelegatedTypeTest::Entry"].to_rbs
    expect = <<~RBS
      class DelegatedTypeTest::Entry < ::ActiveRecord::Base
        def entryable_class: () -> (Message | Comment)
        def entryable_name: () -> String
        def build_entryable: () -> (Message | Comment)
        def message?: () -> bool
        def message: () -> Message?
        def message_id: () -> Integer?
        def comment?: () -> bool
        def comment: () -> Comment?
        def comment_id: () -> Integer?
      end
    RBS
    unless expect == actual
      t.error("expect=\n```rbs\n#{expect}```\n, but got \n```rbs\n#{actual}```\n")
    end
  end
end
