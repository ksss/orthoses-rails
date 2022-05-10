# frozen_string_literal: true

require "bundler/gem_tasks"
require "rgot/cli"

task :test do
  Rgot::Cli.new(%w[-v --require active_support/all --require orthoses/rails lib]).run
end

task default: :test
