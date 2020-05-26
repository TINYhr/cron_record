[![Build Status](https://travis-ci.org/TINYhr/cron_record.svg?branch=master)](https://travis-ci.org/TINYhr/cron_record)

# Disclaim
__This project is still in beta stage__

# CronRecord

Allow records act as crontab. Set a `cron` attribute to record with value is a cron string, then and query them out by time.

__Note:__ Minute argument are passed to match cron pattern but isn't used. This gem run with hourly precise.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cron_record'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cron_record

## Usage

```ruby
class MockModel1 < ActiveRecord::Base
  extend CronRecord::Cronable
  cronable :cron
  # Model has columns/attributes below, with type bigint:
  # attributes['cron_hour']
  # attributes['cron_day']
  # attributes['cron_month']
  # attributes['cron_day_of_week']
end

# Create
a = MockModel1.create!(cron: '0 0 1 1 *')
b = MockModel1.create!(cron: '0 0 2 1 *')

# Query
moment = Time.new(2020, 1, 1, 0, 0, 0)
MockModel1.cron_execute_at(moment).all
#=> a
```

## Testing

Currently, cron_record doesn't fully support all cron functions. But for the supported cron subset, it must be correct. I use `fugit` to verify it. [Attribute tests](spec/integrate/attribute_spec.rb) is built to scan through all possible supported cron string, and make sure it match with fugit.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/TINYhr/cron_record. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the CronRecord project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/TINYhr/cron_record/blob/master/CODE_OF_CONDUCT.md).
