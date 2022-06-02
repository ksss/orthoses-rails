# frozen_string_literal: true

module Orthoses
  module ActiveRecord
    class KnownSig
      include Orthoses::Rails::KnownSigHelper

      def initialize(loader)
        @loader = loader
      end

      def call
        @loader.call.tap do |store|
          paths = best_version_paths(::ActiveRecord::VERSION::STRING, __dir__)
          env = Content::Environment.load_from_paths(paths)
          env.write_to(store: store)
        end
      end
    end
  end
end
