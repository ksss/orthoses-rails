# frozen_string_literal: true

module Orthoses
  module ActiveRecord
    class KnownSig
      def initialize(loader)
        @loader = loader
      end

      def call
        @loader.call.tap do |store|
          paths = Dir.glob("#{File.expand_path("known_sig", __dir__)}/**/*.rbs")
          env = Content::Environment.load_from_paths(paths)
          env.write_to(store: store)
        end
      end
    end
  end
end
