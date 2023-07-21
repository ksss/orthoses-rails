# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in orthoses-rails.gemspec
gemspec

gem "orthoses"# , path: "../orthoses"
gem "rbs"# , path: "../rbs"

gem "rake", github: "ruby/rake"
gem "rgot", "~> 1.4"

gem "debug"
gem "set"
gem "sorted_set"
gem "bcrypt"
gem "steep"

case ENV['RAILS_VERSION']
when "6.0"
  gem "rails", ">= 6.0", "< 6.1"
when "6.1"
  gem "rails", ">= 6.1", "< 7"
when "7.0"
  gem "rails", ">= 7.0", "< 7.1"
else
  gem "rails"
end
