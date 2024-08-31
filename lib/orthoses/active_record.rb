# frozen_string_literal: true

require_relative 'active_record/belongs_to'
require_relative 'active_record/delegated_type'
require_relative 'active_record/enum'
require_relative 'active_record/generated_attribute_methods'
require_relative 'active_record/has_many'
require_relative 'active_record/has_one'
require_relative 'active_record/persistence'
require_relative 'active_record/query_methods'
require_relative 'active_record/relation'
require_relative 'active_record/scope'
require_relative 'active_record/secure_token'

module Orthoses
  module ActiveRecord
    # Thanks https://github.com/pocke/rbs_rails/blob/8a128a8d29f0861aa2c25aa4110ff7c2ea674865/lib/rbs_rails/active_record.rb#L525-L551
    def self.sql_type_to_rbs(t)
      case t
      when :integer, :big_integer
        '::Integer'
      when :float
        '::Float'
      when :decimal
        '::BigDecimal'
      when :string, :text, :citext, :uuid, :binary, :immutable_string
        '::String'
      when :datetime
        '::ActiveSupport::TimeWithZone'
      when :boolean
        "bool"
      when :date
        '::Date'
      when :time
        '::Time'
      when :cidr, :inet
        "::IPAddr"
      when :bit, :bit_varying, :enum, :hstore,
           :interval, :jsonb, :json, :legacy_point, :money, :point, :vector, :xml
        # FIXME
        'untyped'
      else
        # Unknown column type, give up
        'untyped'
      end
    end

    def self.reflection_klass_name(ref)
      Utils.module_name(ref.klass)
    rescue NameError, ArgumentError => e
      while e
        Orthoses.logger.warn(e.message)
        e = e.cause
      end

      nil
    end
  end
end
