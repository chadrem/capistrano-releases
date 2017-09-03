module Capistrano
  module Releases
    # Class for pushing/pulling Capistrano releases.
    class Manager
      attr_reader :params

      class << self
        attr_reader :defaults
      end

      class << self
        attr_writer :defaults
      end

      def initialize(parameters = {})
        @params = parameters

        params[:bucket] ||=
          defaults[:bucket] || raise('bucket_name is a required parameter')

        params[:deploy_to] ||=
          defaults[:deploy_to] || raise('deploy_to is a required parameter')

        params[:keep_releases] ||=
          (defaults[:keep_releases] || 5)
      end

      def push
        make_dirs

        remotes = Set.new(remote_releases)
        puts "Remote releases: #{remotes.to_a.inspect}"

        to_upload_releases = local_releases.reject { |r| remotes.include?(r) }
        to_upload_releases.each do |r|
          puts "Uploading release: #{r}"
          upload_release(r)
        end

        puts "Setting remote current to: #{remote_current}"
        self.remote_current = local_current

        upload_bundle

        to_upload_releases
      end

      def pull
        make_dirs

        locals = Set.new(local_releases)
        puts "Local releases: #{locals.to_a.inspect}"

        to_download_releases = remote_releases.last(params[:keep_releases])
                                              .reject { |r| locals.include?(r) }
        to_download_releases.each do |r|
          puts "Downloading release: #{r}"
          download_release(r)
        end

        self.local_current = remote_current

        puts "Setting local current to: #{local_current}"
        Dir.chdir(File.join(params[:deploy_to], 'current'))

        download_bundle

        to_download_releases
      end

      private

      def make_dirs
        dirs = %w[
          shared
          shared/public
          shared/public/assets
          shared/public/system
          shared/log
          shared/tmp
          shared/tmp/cache
          shared/tmp/pids
          shared/tmp/sockets
          shared/vendor
          releases
        ]

        dirs.each do |dir|
          full_dir = File.join(params[:deploy_to], dir)
          unless Dir.exist?(full_dir)
            Dir.mkdir(full_dir)
            puts "Creating directory: #{full_dir}"
          end
        end
      end

      def defaults
        self.class.defaults || {}
      end

      def local_releases_path
        File.join(params[:deploy_to], 'releases')
      end

      def local_shared_path
        File.join(params[:deploy_to], 'shared')
      end

      def local_releases
        Dir.glob("#{local_releases_path}/*")
           .sort
           .map { |r| r.split('/').last }.sort
      end

      def remote_releases
        bucket.objects
              .map(&:key)
              .select { |k| k =~ /\A\d+.*\.tar\.gz\z/ }
              .map { |k| k.gsub(/\.tar\.gz\z/, '') }
              .sort
      end

      def local_current
        File.readlink(File.join(params[:deploy_to], 'current')).split('/').last
      end

      def remote_current
        bucket.object('current.txt').get.body.read
      end

      def local_current=(release)
        cur_path = File.join(params[:deploy_to], 'current')
        rel_path = File.join(local_releases_path, release)

        File.unlink(cur_path) if File.symlink?(cur_path)
        File.symlink(rel_path, cur_path)

        nil
      end

      def remote_current=(release)
        bucket.object('current.txt').put(body: release)

        nil
      end

      def upload_release(release)
        tmp = Tempfile.new(["capistrano-releases_upload-release-#{release}", '.tar.gz'],
                           Dir.tmpdir, encoding: 'BINARY')

        begin
          system!(['tar', 'Ccfz', local_releases_path, tmp.path, release])
          bucket.object("#{release}.tar.gz").put(body: tmp)
        ensure
          tmp.close
          tmp.unlink
        end
      end

      def download_release(release)
        tmp = Tempfile.new(["capistrano-releases_download-release-#{release}", '.tar.gz'],
                           Dir.tmpdir, encoding: 'BINARY')

        begin
          bucket.object("#{release}.tar.gz").get(response_target: tmp)
          system!(['tar', 'Cxfz', local_releases_path, tmp.path])
        ensure
          tmp.close
          tmp.unlink
        end
      end

      def upload_bundle
        return unless Dir.exist?(File.join(local_shared_path, 'bundle'))

        puts 'Uploading bundle'

        tmp = Tempfile.new(['capistrano-releases_upload-bundle', '.tar.gz'],
                           Dir.tmpdir, encoding: 'BINARY')

        begin
          system!(['tar', 'Ccfz', local_shared_path, tmp.path, 'bundle'])
          bucket.object('bundle.tar.gz').put(body: tmp)
        ensure
          tmp.close
          tmp.unlink
        end
      end

      def download_bundle
        return if Dir.exist?(File.join(local_shared_path, 'bundle'))

        puts 'Downloading bundle'

        tmp = Tempfile.new(['capistrano-releases_download-bundle', '.tar.gz'],
                           Dir.tmpdir, encoding: 'BINARY')

        begin
          bucket.object('bundle.tar.gz').get(response_target: tmp)
          system!(['tar', 'Cxfz', local_shared_path, tmp.path])
        ensure
          tmp.close
          tmp.unlink
        end
      end

      def bucket
        @bucket ||= Aws::S3::Bucket.new(params[:bucket])
      end

      def system!(cmd_array)
        raise 'Must be an array' unless cmd_array.is_a?(Array)
        cmd = cmd_array.map { |c| Shellwords.shellescape(c) }.join(' ')
        raise "command failed: #{cmd}" unless system(cmd)
      end
    end
  end
end
