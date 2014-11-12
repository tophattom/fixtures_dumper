# FixturesDumper

Dump data from development or test database to fixtures easily.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fixtures_dumper'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fixtures_dumper

## Usage

``` ruby
rake db:fixtures:dump # Dump data in all the tables to fixtures
rake db:fixtures:dump TABLE=foo # Dump data from `foo` to its fixture file
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/fixtures_dumper/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
