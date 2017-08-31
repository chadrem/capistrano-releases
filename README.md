# Capistrano::Releases
Auto scaling AWS EC2 environments need a way to share the Capistrano 'releases' directory and 'current' symlink.
This gem provides that capability using AWS S3 to store releases.
Each release is stored as a zip file.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'capistrano-releases'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capistrano-releases

## Usage

    $ releases --help

## Development

After checking out the repo, run `bin/setup` to install dependencies.
Then, run `rake test` to run the tests.
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/chadrem/capistrano-releases.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
