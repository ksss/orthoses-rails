module ConcernTest
  LOADER = -> {
    module Mod
      extend ActiveSupport::Concern
      class_methods do
        def class_m
        end
      end
      def instance_m
      end
    end
  }
  def test_class_methods(t)
    store = Orthoses::ActiveSupport::Concern.new(
      Orthoses::Store.new(LOADER)
    ).call

    expect = <<~RBS
      module ConcernTest::Mod::ClassMethods
        public

        def class_m: () -> untyped
      end
    RBS
    actual = store["ConcernTest::Mod::ClassMethods"].to_rbs
    unless expect == actual
      t.error("expect=\n```rbs\n#{expect}```\n, but got \n```rbs\n#{actual}```\n")
    end
  end
end
