begin
  require 'test_helper'
rescue LoadError
end

module BaseTest
  LOADER = ->{
    class UserMailer < ::ActionMailer::Base
      def foo(a, b = nil, *c, d:, e: nil, **f)
      end

      private

      def bar
      end
    end
  }
  def test_action_methods(t)
    store = Orthoses::ActionMailer::Base.new(
      Orthoses::Store.new(LOADER)
    ).call
    expect = <<~RBS
      class BaseTest::UserMailer < ::ActionMailer::Base
        def self.foo: (untyped a, ?untyped b, *untyped c, d: untyped, ?e: untyped, **untyped f) -> ::ActionMailer::MessageDelivery
      end
    RBS
    actual = store['BaseTest::UserMailer'].to_rbs
    unless expect == actual
      t.error("expect=\n```rbs\n#{expect}```\n, but got \n```rbs\n#{actual}```\n")
    end
  end
end
