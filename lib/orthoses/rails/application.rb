# frozen_string_literal: true

module Orthoses
  module Rails
    class Application
      def initialize(loader)
        @loader = loader
      end

      def call
        loader = @loader
        Orthoses::Builder.new do
          use Orthoses::ActiveModel::HasSecurePassword
          use Orthoses::ActiveRecord::BelongsTo
          use Orthoses::ActiveRecord::DelegatedType
          use Orthoses::ActiveRecord::Enum
          use Orthoses::ActiveRecord::GeneratedAttributeMethods
          use Orthoses::ActiveRecord::HasMany
          use Orthoses::ActiveRecord::HasOne
          use Orthoses::ActiveRecord::Relation
          use Orthoses::ActiveRecord::Scope

          use Orthoses::ActiveSupport::ClassAttribute
          use Orthoses::ActiveSupport::Concern
          use Orthoses::ActiveSupport::Delegation
          use Orthoses::ActiveSupport::Configurable
          use Orthoses::ActiveSupport::MattrAccessor
          reset_runner loader
        end.call
      end
    end
  end
end