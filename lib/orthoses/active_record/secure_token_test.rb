begin
  require 'test_helper'
rescue LoadError
end

module SecureTokenTest
  LOADER = ->(){
    class User < ActiveRecord::Base
      has_secure_token
      has_secure_token :auth_token
    end
  }

  def test_has_secure_token(t)
    store = Orthoses::ActiveRecord::SecureToken.new(
      Orthoses::Store.new(LOADER)
    ).call

    actual = store.map { |_, content| content.to_rbs }.join("\n")
    expect = <<~RBS
      class SecureTokenTest::User < ::ActiveRecord::Base
        def regenerate_token: () -> bool
        def regenerate_auth_token: () -> bool
      end
    RBS
    unless expect == actual
      t.error("expect=\n```rbs\n#{expect}```\n, but got \n```rbs\n#{actual}```\n")
    end
  end
end
