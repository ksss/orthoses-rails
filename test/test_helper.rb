require 'orthoses-rails'
require 'rgot/cli'
require 'action_mailer'
require 'active_record'
require 'active_support/all'
require 'zeitwerk'

Orthoses.logger.level = :error
exit Rgot::Cli.new(["-v", $PROGRAM_NAME, *ARGV]).run
