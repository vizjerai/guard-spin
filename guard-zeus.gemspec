# -*- encoding: utf-8 -*-
require File.expand_path('../lib/guard/zeus/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "guard-zeus"
  gem.version       = Guard::ZeusVersion::VERSION
  gem.platform      = Gem::Platform::RUBY
  gem.authors       = ["jonathangreenberg", "Andrew Assarattanakul", "Rob Sharp"]
  gem.email         = ["greenberg@entryway.net", "assarata@gmail.com", "qnm@fea.st"]
  gem.description   = %q{Guard::Zeus automatically manage zeus}
  gem.summary       = %q{Pushes watched files to Zeus}
  gem.homepage      = "http://github.com/qnm/guard-zeus"

  gem.add_dependency 'guard'
  gem.add_dependency 'zeus'

  gem.add_development_dependency 'bundler', '>= 1.0'
  gem.add_development_dependency 'rspec', '>= 2.0'

  gem.files         = Dir.glob('{lib}/**/*') + %w[LICENSE README.md]
  gem.require_path  = 'lib'
end
