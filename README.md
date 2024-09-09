# IdentityValidations

This gem provides validation modules for models that are duplicated in the [identity-idp][idp] and [identity-dashboard][dashboard] repositories. The goal is to provide a unified validation of shared models so that a valid instance in the dashboard is equally valid in the IDP.

[idp]: https://github.com/18F/identity-idp
[dashboard]: https://github.com/18f/identity-dashboard

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'identity_validations', github: '18F/identity_validations'
```

And then execute:

    $ bundle

## Usage

For the models that currently have validation defined in this gem (e.g., ServiceProvider), simply remove any existing validation code and include the appropriate validation module, e.g.:

```ruby
class ServiceProvider
  include IdentityValidations::ServiceProviderValidation
  ...
end
```

### Secondary Usage

You can also pull in individual validators. To help keep both code and data consistent, please try using the `include` example defined above and use the individual validators only if the `include` above is completely unsuitable for your context. You can use the individual validators like so:

```ruby
class SetupStep < ActiveRecord::Model
  validates_with IdentityValidations::UriValidator, attribute: :push_notification_url
end
```

These validators accept a custom option, `attribute:` instead of using the Rails `validate :push_notification_url, ...` because that would require applications using this gem to use code like

```ruby
  # Don't do this. It won't work
  validate :push_notification_url, allow_blank: true, :'identity_validations/uri' => true
```

and our concern was it that this would be more confusing when searching through the code. With the working version above, you can search by class name through a variety of repos to get a comprehensive sense of everywhere that the `UriValidator` class is in use.

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

Given that this gem only holds modules that are expected to be included in an ActiveRecord model, we defer testing to the repositories that will apply these validations.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/18F/identity_validations. See [CONTRIBUTING][contributing] for details.

[contributing]: https://github.com/18F/identity_validations/blob/master/CONTRIBUTING.md
