# Capistrano::Releases

This gem simplifies working with [Auto scaling for AWS EC2](https://aws.amazon.com/autoscaling/) and [Capistrano](http://capistranorb.com). It does this by storing your releases in AWS S3 and synchronizing them when needed (after deploy, instance reboot, and after a new instance is created).

## Requirements

* Ruby 2.X or greater
* [aws-sdk](https://github.com/aws/aws-sdk-ruby) 2.X or greater
* An AWS S3 bucket to store releases
* Read and write API permissions to the S3 bucket
* Capistrano installed and configured properly with deploys already working

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

It is assumed that you have already setup a S3 bucket and granted API read/write permissions to it.
You should test to make sure your instances are able to read/write to the bucket before continuing.

You normally interact with the gem through the command line (see below for flag details):

    $ releases --help

The general idea is that after each deploy, you 'push' the new release to S3.
Then, after each boot (or reboot) your instances 'pull' the latest releases from S3.

For 'push' you need to edit your *deploy.rb* and add something like this:

    namespace :releases do
        bucket = 'your-bucket-name-goes-here'
        
        desc 'Push releases'
        task :push do
            on roles(:all, primary: true) do
                execute "releases -b #{bucket} -d #{fetch(:deploy_to)} -m push"
            end
        end
    end
    after 'deploy:finished', 'releases:push'

For 'pull' you need to configure your server to run a command **before** your Rails processes (Puma, Thin, Sidekiq, etc) start:

    $ releases -b your-bucket-name-goes-here -d /your/deploy/to/name/goes/here -m pull
    
You must now write a boot script for your Rails processes.
These tend to be very specific to your environment and the set of Capistrano gems you are using.
An example is provided below.

## Flags

#### --mode

You must pick a mode to run in: 'push' or 'pull'.

The push mode compare your local releases to those stored in S3.
Any missing releases will get compressed and uploaded.
The 'current' symlink version will also get uploaded.

The pull mode compares the releases stored in S3 to your local releases.
Any missing releases will get downloaded and uncompressed.
Finally, the 'current' symlink will get updated to match the remote version.

#### --bucket

Your instances must have read/write access to the specified S3 bucket.
Make sure your instances have the correct permissions with an IAM role
or make sure you specify the ````AWS_ACCESS_KEY_ID```` and ````AWS_SECRET_ACCESS_KEY```` environment variables.
Under the hood this gem uses the [aws-sdk](https://github.com/aws/aws-sdk-ruby) gem for all API calls.

#### --deploy-to

This flag must be set to match the Capistrano configuration variable of the same name.
You can normally find it in your *deploy.rb*. An example from a stock config:

    set :deploy_to, "/var/www/my_app_name"

## Rails boot script

This is just a sample.
You will need to modify it based on your Capistrano configuration.
Watch the commands that are executed when you run ````cap production deploy```` to see what commands are executed.
Also make sure you run it as ````:deploy_user```` user as specified in your *deploy.rb*.

    #!/bin/bash

    echo '***** pulling releases *****' &&
    releases -b my-releases-bucket -d /apps/my-app -m pull &&
    
    echo '***** Deleting old PID files *****' &&
    rm -rf /apps/my-app/shared/tmp/pids/* &&
    
    echo '***** Installing gems *****' &&
    bundle install --path /apps/my-app/shared/bundle --without development test --deployment --quiet &&

    echo '***** Precompiling assets *****' &&
    bundle exec rake assets:precompile &&
    
    echo '***** Starting web server *****' &&
    echo 'put your web server command here' &&
    
    echo '***** Starting job server *****' &&
    echo 'put your job server command here' &&

## Development

After checking out the repo, run `bin/setup` to install dependencies.
Then, run `rake test` to run the tests.
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/chadrem/capistrano-releases.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
