require 'orthoses-rails'
require 'rgot/cli'
require 'active_record'
require 'active_support/all'

Orthoses.logger.level = :error
exit Rgot::Cli.new(["-v", $PROGRAM_NAME, *ARGV]).run
