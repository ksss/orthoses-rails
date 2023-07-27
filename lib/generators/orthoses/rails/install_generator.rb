# frozen_string_literal: true

require 'rails/generators/base'
require 'orthoses/rails'

module Orthoses
  module Rails
    module Generators
      class InstallGenerator < ::Rails::Generators::Base
        source_root File.expand_path('templates', __dir__)

        def copy_rake_task_file
          copy_file "rails.rake", "lib/tasks/orthoses/rails.rake"
        end
      end
    end
  end
end
