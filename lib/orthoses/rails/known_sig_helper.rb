# frozen_string_literal: true

module Orthoses
  module Rails
    module KnownSigHelper
      def best_version_paths(current, base_dir)
        best_version = find_best_version(current, base_dir)
        Dir.glob("#{File.expand_path("known_sig", base_dir)}/#{best_version}/**/*.rbs")
      end

      def find_best_version(current, base_dir)
        current_v = Gem::Version.new(current)
        versions = version_dir(base_dir)
        versions.reverse.bsearch { |v| v <= current_v } || versions.first
      end

      def version_dir(base_dir)
        Dir.glob("#{File.expand_path("known_sig", base_dir)}/*")
          .map(&File.method(:basename))
          .map(&Gem::Version.method(:new))
          .sort
      end
    end
  end
end
