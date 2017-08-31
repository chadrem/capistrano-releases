module Capistrano
  module Releases
    # Command line interface class for Manager class.
    class CLI
      def run
        options = {}

        parser = OptionParser.new do |opts|
          opts.banner = 'Usage: manager [options]'

          opts.on('-bBUCKET', '--bucket=BUCKET',
                  'S3 bucket to pull/push releases.') do |v|
            options[:bucket] = v
          end

          opts.on('-dDEPLOY_TO', '--deploy-to=DEPLOY_TO',
                  'App directory to deploy to.') do |v|
            options[:deploy_to] = v
          end

          opts.on('-mMODE', '--mode=MODE',
                  "Mode to run: 'push' or 'pull'") do |v|
            options[:mode] = v
          end
        end

        parser.parse!

        unless options[:bucket]
          puts('-b or --bucket is a required option.') && exit(1)
        end

        unless options[:deploy_to]
          puts('-d or --deploy-to is a required option.') && exit(1)
        end

        puts('-m or --mode is a required option.') && exit(1) unless options[:mode]

        manager = ::Capistrano::Releases::Manager.new(options)

        case options[:mode]
        when 'push'
          manager.push
        when 'pull'
          manager.pull
        else
          puts 'Invalid mode.'
          exit(1)
        end
      end
    end
  end
end
