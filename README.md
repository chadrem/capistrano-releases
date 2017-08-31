# Capistrano::Releases
Auto scaling AWS EC2 environments need a way to share the Capistrano 'releases' directory and 'current' symlink.
This gem provides that capability using AWS S3 to store releases.
Each release is stored as a zip file.

## Requirements

* Ruby 2.X or greater.
* aws-sdk gem.
* An AWS S3 bucket to store releases.
* Read and write API permissions to the S3 bucket.

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

#### Flag: --mode

You must pick a mode to run in: 'push' or 'pull'.

The push mode compare your local releases to those stored in S3.
Any missing releases will get compressed and uploaded.
The 'current' symlink version will also get uploaded.

The pull mode compares the releases stored in S3 to your local releases.
Any missing releases will get downloaded and uncompressed.
Finally, the 'current' symlink will get updated to match the remote version.

#### Flag: --bucket

Your instance(s) must have read/write access to the specified S3 bucket.
Make sure your instance has the correct permissions with an IAM role
or make sure you specify the ````AWS_ACCESS_KEY_ID```` and ````AWS_SECRET_ACCESS_KEY```` environment variables.
Under the hood this gem uses the [aws-sdk](https://github.com/aws/aws-sdk-ruby) gem for all API calls.

#### Flag: --deploy-to

This flag must be set to match the Capistrano configuration variable of the same name.
You can normally find it in your ````deploy.rb````. An example from a stock config:

    set :deploy_to, "/var/www/my_app_name"

## Development

After checking out the repo, run `bin/setup` to install dependencies.
Then, run `rake test` to run the tests.
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/chadrem/capistrano-releases.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
