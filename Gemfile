# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in orthoses-rails.gemspec
gemspec

gem "orthoses"# , path: "../orthoses"
gem "rbs"# , path: "../rbs"

gem "rake"
gem "rgot", "~> 1.4"

gem "debug"
gem "set"
gem "sorted_set"
gem "bcrypt"
gem "steep"

case ENV['RAILS_VERSION']
when "7.2"
  gem "rails", ">= 7.2", "< 7.3"
when "8.0"
  gem "rails", ">= 8.0", "< 8.1"
when "8.1"
  gem "rails", ">= 8.1", "< 8.2"
else
  gem "rails"
end
