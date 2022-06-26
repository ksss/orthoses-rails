# frozen_string_literal: true

require_relative 'active_support/class_attribute'
require_relative 'active_support/configurable'
require_relative 'active_support/delegation'
require_relative 'active_support/mattr_accessor'
require_relative 'active_support/time_with_zone'

module Orthoses
  module ActiveSupport
    # Interface for adding middleware in bulk.
    #     Orthoses::ActiveSupport.each do |middleware, **args|
    #       use middleware, **args
    #     end
    def self.each
      yield ClassAttribute
      yield Delegation
      yield MattrAccessor
      yield TimeWithZone
    end
  end
end
