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

      # You can use other publicly available middleware.
      # `Orthoses::YARD` is available at https://github.com/ksss/orthoses-yard.
      # By using this middleware, you can add the capability
      # to generate type information from YARD documentation.
      # use Orthoses::YARD,
      #   parse: ['{app,lib}/**/*.rb']

      # You can load hand written RBS.
      # use Orthoses::LoadRBS,
      #   paths: Dir.glob(Rails.root / "sig/hand-written/**/*.rbs")

      # Middleware package for rails application.
      use Orthoses::Rails::Application

      # Application code loaded here is the target of the analysis.
      run Orthoses::Rails::Application::Loader.new
    end.call
  end
end
