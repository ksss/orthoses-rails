# frozen_string_literal: true

require 'orthoses'

require_relative "rails/version"

require_relative 'active_model/has_secure_password'

require_relative 'active_record/generated_attribute_methods'
require_relative 'active_record/has_many'
require_relative 'active_record/has_one'
require_relative 'active_record/belongs_to'

require_relative 'active_support/class_attribute'
require_relative 'active_support/concern'
require_relative 'active_support/mattr_accessor'
require_relative 'active_support/time_with_zone'
