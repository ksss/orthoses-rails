# Orthoses::Rails

[Orthoses](https://github.com/ksss/orthoses) extension for Ruby on Rails.
Orthoses::Rails automatically generates RBS for methods added by Rails.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add orthoses-rails

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install orthoses-rails

## Usage

```rb
Orthoses::Builder.new do
  use Orthoses::CreateFileByName
    base_dir: Rails.root.join("sig/out"),
    header: "# !!! GENERATED CODE !!!"
  use Orthoses::Filter,
    if: -> (name, _content) {
      path, _lineno = Object.const_source_location(name)
      return false unless path
      %r{app/models}.match?(path)
    }
  use YourCustom::Middleware
  use Orthoses::ActiveModel::HasSecurePassword
  use Orthoses::ActiveRecord::BelongsTo
  use Orthoses::ActiveRecord::GeneratedAttributeMethods
  use Orthoses::ActiveRecord::HasMany
  use Orthoses::ActiveRecord::HasOne
  use Orthoses::ActiveSupport::Concern
  use Orthoses::ActiveSupport::ClassAttribute
  use Orthoses::ActiveSupport::MattrAccessor
  use Orthoses::ActiveSupport::TimeWithZone
  use Orthoses::Mixin
  use Orthoses::Constant, strict: false
  use Orthoses::ObjectSpaceAll
  run -> () {
    Rake::Task[:environment].invoke
    Rails.application.eager_load!
    Orthoses::Utils.unautoload!
  }
end.call
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ksss/orthoses-rails. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/ksss/orthoses-rails/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Orthoses::Rails project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ksss/orthoses-rails/blob/main/CODE_OF_CONDUCT.md).
