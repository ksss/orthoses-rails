# frozen_string_literal: true

require_relative "lib/orthoses/rails/version"

Gem::Specification.new do |spec|
  spec.name = "orthoses-rails"
  spec.version = Orthoses::Rails::VERSION
  spec.authors = ["ksss"]
  spec.email = ["co000ri@gmail.com"]

  spec.summary = "Orthoses middleware collection for Ruby on Rails"
  spec.description = "Orthoses middleware collection for Ruby on Rails"
  spec.homepage = "https://github.com/ksss/orthoses-rails"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    [
      %w[CODE_OF_CONDUCT.md LICENSE.txt README.md],
      Dir.glob("lib/**/*.*").grep_v(/_test\.rb\z/),
      Dir.glob("sig/**/*.rbs")
    ].flatten
  end

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "orthoses", ">= 1.13"
end
