namespace :orthoses do
  task :rails do
    # Phase to load libraries
    require Rails.root / "config/application"
    require 'orthoses/rails'

    # You can choose logger level
    Orthoses.logger.level = :warn

    # DSL for Orthoses.
    Orthoses::Builder.new do
      use Orthoses::CreateFileByName,
        to: 'sig/orthoses', # Write to this dir. (require)
        depth: 1,           # Group files by module name path depth. (default: nil)
        rmtree: true        # Remove all `to` dir before generation. (default: false)

      # Complement missing const name.
      use Orthoses::MissingName

      # You can load hand written RBS.
      # use Orthoses::LoadRBS,
      #   paths: Dir.glob(Rails.root / "sig/hand-written/**/*.rbs")

      # Auto detect const type in store.
      use Orthoses::Constant

      # Middleware package for rails application.
      use Orthoses::Rails::Application

      # You can also be customized to include output equivalent to `$ rbs prototype rb` command.
      # However, you will have to deal with the problems inherent in static analysis.
      # use Orthoses::RBSPrototypeRB,
      #   paths: Dir.glob(Rails.root / "app/models/**/*.rb"),
      #   method_definition_filter: nil,
      #   alias_filter: nil,
      #   constant_filter: ->(member) { false },
      #   mixin_filter: ->(member) { false },
      #   attribute_filter: ->(member) { false }

      # Application code loaded here is the target of the analysis.
      run -> {
        Rails.application.initialize!
        Rails.application.eager_load!
      }
    end.call
  end
end
