# frozen_string_literal: true

require "bundler/gem_tasks"
require "rgot/cli"

task :test do
  require 'orthoses/rails'

  exit Rgot::Cli.new(%w[-v --require active_record --require active_support/all --require action_mailer --require zeitwerk lib]).run
end

task default: :test
