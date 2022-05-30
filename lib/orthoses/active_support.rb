# frozen_string_literal: true

require_relative 'active_support/all'
require_relative 'active_support/class_attribute'
require_relative 'active_support/concern'
require_relative 'active_support/delegation'
require_relative 'active_support/mattr_accessor'
require_relative 'active_support/time_with_zone'
require_relative 'active_support/known_sig'

module Orthoses
  module ActiveSupport
    # Interface for adding middleware in bulk.
    #     Orthoses::ActiveSupport.each do |middleware, **args|
    #       use middleware, **args
    #     end
    def self.each
      yield ClassAttribute
      yield Concern
      yield Delegation
      yield MattrAccessor
      yield TimeWithZone
      yield KnownSig
    end
  end
end
