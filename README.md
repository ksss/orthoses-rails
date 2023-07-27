# Orthoses::Rails

[Orthoses](https://github.com/ksss/orthoses) extension for Ruby on Rails.
Orthoses::Rails automatically generates RBS for methods added by Rails.

## Usage

Build your Rake task for RBS generation.

```rb
$ bin/rails generate orthoses:rails:install
```

Then run the rake task.

```
$ bin/rails orthoses:rails
```

## Features

### Orthoses::ActiveModel

- `HasSecurePassword`
  - Add signatures that generated form `has_secure_password`.

### Orthoses::ActiveRecord

- `BelongsTo`
  - Add signatures that generated form `belongs_to`.
- `DelegatedType`
  - Add signatures that generated from `delegated_type`
- `Enum`
  - Add signatures that generated from `enum`
- `HasMany`
  - Add signatures that generated form `has_many`.
- `HasOne`
  - Add signatures that generated form `has_one`.
- `Scope`
  - Add signatures that generated form `scope`.

### Orthoses::ActiveSupport

- `ClassAttribute`
  - Add signatures that generated form `class_attribute`.
- `Configurable`
  - Add signatures that generated from `config_accessor`
- `Delegation`
  - Add signatures that generated from `delegate`. The type definition of the method or instance variable specified by `to` is required.
- `MattrAccessor`
  - Add signatures that generated form `mattr_accessor`, `cattr_accessor`, `mattr_reader`, `cattr_reader`, `mattr_writer` and `cattr_writer`.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add orthoses-rails

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install orthoses-rails

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ksss/orthoses-rails. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/ksss/orthoses-rails/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Orthoses::Rails project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ksss/orthoses-rails/blob/main/CODE_OF_CONDUCT.md).
