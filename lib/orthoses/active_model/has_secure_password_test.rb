module HasSecurePasswordTest
  LOADER = ->(){
    class User < ActiveRecord::Base
      has_secure_password
    end
  }
  def test_has_secure_password(t)
    require 'active_record'

    store = Orthoses::ActiveModel::HasSecurePassword.new(
      Orthoses::Store.new(LOADER)
    ).call

    full_name =
      if ActiveRecord::VERSION::MAJOR < 6
        "ActiveModel::SecurePassword::InstanceMethodsOnActivation"
      else
        "HasSecurePasswordTest::User::ActiveModel_SecurePassword_InstanceMethodsOnActivation_password"
      end

    expect = <<~RBS
      module #{full_name}
        attr_reader password: String?

        def password=: (String) -> String

        def password_confirmation=: (String) -> String

        def authenticate_password: (String) -> (HasSecurePasswordTest::User | false)

        alias authenticate authenticate_password
      end
    RBS
    actual = store[full_name].to_rbs
    unless expect == actual
      t.error("expect=\n```rbs\n#{expect}```\n, but got \n```rbs\n#{actual}```\n")
    end

    expect = <<~RBS
      class HasSecurePasswordTest::User < ::ActiveRecord::Base
        include #{full_name}
      end
    RBS
    actual = store["HasSecurePasswordTest::User"].to_rbs
    unless expect == actual
      t.error("expect=\n```rbs\n#{expect}```\n, but got \n```rbs\n#{actual}```\n")
    end
  end
end
