# frozen_string_literal: true

require "bundler/gem_tasks"
require "rgot/cli"

task :test do
  require 'orthoses/rails'
  require 'active_support/all'

  Rgot::Cli.new(%w[-v lib]).run
end

task default: :test
