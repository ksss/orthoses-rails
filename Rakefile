# frozen_string_literal: true

require "bundler/gem_tasks"
require "rgot/cli"

task :test do
  require 'orthoses/rails'

  # Create cache for performance
  Orthoses::Utils.rbs_environment(collection: true)

  Rgot::Cli.new(%w[-v --require active_record --require active_support/all lib]).run
end

task default: :test
