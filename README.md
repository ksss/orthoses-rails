# Orthoses::Rails

[Orthoses](https://github.com/ksss/orthoses) extension for Ruby on Rails.
Orthoses::Rails automatically generates RBS for methods added by Rails.

## Usage

If you have never performed rbs collection initialization, you need to do it.

```
$ bundle exec rbs collection init
$ bundle exec rbs collection install
```

Build your Rake task for RBS generation.

```
$ bundle exec rails generate orthoses:rails:install
```

Then run the rake task.

```
$ bundle exec rails orthoses:rails
```

Output is stored in the `sig/orthoses` directory.

## Output example

```rb
class User < ApplicationRecord
  has_one :email_account, dependent: :destroy
end
```

```rbs
class User < ::ApplicationRecord
  include User::GeneratedAssociationMethods
  include User::GeneratedAttributeMethods
  extend User::ActiveRecord_Persistence_ClassMethods
  extend _ActiveRecord_Relation_ClassMethods[User, User::ActiveRecord_Relation, Integer]
end

class User::ActiveRecord_Associations_CollectionProxy < ::ActiveRecord::Associations::CollectionProxy
  include _ActiveRecord_Relation[User, Integer]
  include Enumerable[User]
end

module User::ActiveRecord_Persistence_ClassMethods
  def build: (?id: Integer, ?created_at: ActiveSupport::TimeWithZone?, ?updated_at: ActiveSupport::TimeWithZone?, ?nickname: String?, **untyped) ?{ (User) -> void } -> User
           | (Array[Hash[Symbol, untyped]]) ?{ (User) -> void } -> Array[User]

  def create: (?id: Integer, ?created_at: ActiveSupport::TimeWithZone?, ?updated_at: ActiveSupport::TimeWithZone?, ?nickname: String?, **untyped) ?{ (User) -> void } -> User
            | (Array[Hash[Symbol, untyped]]) ?{ (User) -> void } -> Array[User]

  def create!: (?id: Integer, ?created_at: ActiveSupport::TimeWithZone?, ?updated_at: ActiveSupport::TimeWithZone?, ?nickname: String?, **untyped) ?{ (User) -> void } -> User
             | (Array[Hash[Symbol, untyped]]) ?{ (User) -> void } -> Array[User]
end

class User::ActiveRecord_Relation < ::ActiveRecord::Relation
  include Enumerable[User]
  include User::GeneratedRelationMethods
  include _ActiveRecord_Relation[User, Integer]
end

module ::User::GeneratedAssociationMethods
  def build_email_account: (?untyped attributes) ?{ (EmailAccount) -> void } -> EmailAccount

  def create_email_account: (?untyped attributes) ?{ (EmailAccount) -> void } -> EmailAccount

  def create_email_account!: (?untyped attributes) ?{ (EmailAccount) -> void } -> EmailAccount

  def email_account: () -> EmailAccount?

  def email_account=: (EmailAccount?) -> EmailAccount?

  # ...snip...
end

module ::User::GeneratedAttributeMethods
  attr_accessor id: ::Integer

  attr_accessor nickname: ::String?

  attr_accessor updated_at: ::ActiveSupport::TimeWithZone?

  attr_accessor created_at: ::ActiveSupport::TimeWithZone?

  # ...snip...
end

module ::User::GeneratedRelationMethods
  # ...snip...
end
```

## Supported methods

### ActionMailer

- Action methods

### ActiveModel

- `attribute`
- `has_secure_password`

### ActiveRecord

- Column attribute methods
- `belongs_to`
- `delegated_type`
- `enum`
- `has_many`
- `has_one`
- Relation and CollectionProxy methods
- `scope`
- `secure_token`

### ActiveStorage

- `has_one_attached`

### ActiveSupport

- `alias_attribute`
- `class_attribute`
- `class_methods`
- `config_accessor`
- `delegate`
- `mattr_accessor`

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
