# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano/releases/version'

Gem::Specification.new do |spec|
  spec.name          = 'capistrano-releases'
  spec.version       = Capistrano::Releases::VERSION
  spec.authors       = ['Chad Remesch']
  spec.email         = ['chad@remesch.com']

  spec.summary       = 'Release manager for auto scaling environments.'
  spec.description   = 'Auto scaling environments need a way to share and synchronize the capistrano releases directory. This gem provides that capability using AWS S3.'
  spec.homepage      = 'https://github.com/chadrem/capistrano-releases'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.0'

  spec.add_dependency 'aws-sdk', '> 2'
end
