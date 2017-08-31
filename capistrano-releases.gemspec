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
  spec.description   = 'Auto scaling environments need a way to share the releases directory. This gem provides that capability using AWS S3.'
  spec.homepage      = 'https://github.com/chadrem/capistrano-releases'
  spec.license       = 'MIT'

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
