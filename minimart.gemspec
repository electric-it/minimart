# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'minimart/version'

Gem::Specification.new do |spec|
  spec.name          = 'minimart'
  spec.version       = Minimart::VERSION
  spec.summary       = %q{MiniMart is a RubyGem that makes it simple to build a repository of Chef cookbooks using only static files.}
  spec.description   = %q{MiniMart is a RubyGem that makes it simple to build a repository of Chef cookbooks using only static files.}
  spec.authors       = ['MadGlory', 'Todd Pickell', 'Others']
  spec.homepage      = 'http://electric-it.github.io/minimart/'
  spec.license       = 'Apache License, v2.0'

  spec.required_ruby_version = '>= 2.2'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'git',          '~> 1.3'
  spec.add_dependency 'minitar',      '~> 0.6'
  spec.add_dependency 'octokit',      '~> 4.3'
  spec.add_dependency 'redcarpet',    '~> 3.4'
  spec.add_dependency 'rest-client',  '~> 2.0'
  spec.add_dependency 'ridley',       '~> 5.1'
  spec.add_dependency 'solve',        '~> 3.1'
  spec.add_dependency 'thor',         '~> 0.19'
  spec.add_dependency 'tilt',         '~> 2.0'
  spec.add_dependency 'sprockets',    '~> 3.5'
  spec.add_dependency 'uglifier',     '~> 3.0'
  spec.add_dependency 'sass',         '~> 3.4'

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake',    '~> 12.0'
  spec.add_development_dependency 'rspec',   '~> 3.4'
  spec.add_development_dependency 'webmock', '~> 2.3'
  spec.add_development_dependency 'vcr',     '~> 3.0'
  spec.add_development_dependency 'dotenv',  '~> 2.1'
end
