begin
  require 'test_helper'
rescue LoadError
end

require "active_storage/attached"
require "active_storage/reflection"

ActiveRecord::Base.include(ActiveStorage::Attached::Model)
ActiveRecord::Base.include(ActiveStorage::Reflection::ActiveRecordExtensions)
ActiveRecord::Reflection.singleton_class.prepend(ActiveStorage::Reflection::ReflectionExtension)

if ActiveRecord.version >= Gem::Version.new("7.2")
  class ::ActiveStorage::Blob
    def self.validate_service_configuration(*); end
  end
end

module ModelTest
  LOADER = ->(){
    class User < ActiveRecord::Base
      has_one_attached :one
      has_many_attached :many
    end
  }

  def test_has_one_many_attached(t)
    store = Orthoses::ActiveStorage::Attached::Model.new(
      Orthoses::Store.new(LOADER)
    ).call

    actual = store.map { |_, content| content.to_rbs }.join("\n")
    expect = <<~RBS
      class ModelTest::User < ::ActiveRecord::Base
        def one: () -> ActiveStorage::Attached::One
        def one=: (untyped attachable) -> untyped
        def many: () -> ActiveStorage::Attached::Many
        def many=: (untyped attachable) -> untyped
      end
    RBS
    unless expect == actual
      t.error("expect=\n```rbs\n#{expect}```\n, but got \n```rbs\n#{actual}```\n")
    end
  end
end
