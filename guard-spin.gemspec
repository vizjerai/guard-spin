# -*- encoding: utf-8 -*-
require File.expand_path('../lib/guard/spin/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "guard-spin"
  gem.version       = Guard::SpinVersion::VERSION
  gem.platform      = Gem::Platform::RUBY
  gem.authors       = ["jonathangreenberg", "Andrew Assarattanakul"]
  gem.email         = ["greenberg@entryway.net", "assarata@gmail.com"]
  gem.description   = %q{Guard gem for Spin}
  gem.summary       = %q{Pushes watched files to Spin}
  gem.homepage      = "http://github.com/vizjerai/guard-spin"

  gem.add_dependency 'guard'
  gem.add_dependency 'spin'

  gem.files         = Dir.glob('{lib}/**/*') + %w[LICENSE README.md]
  gem.require_path  = 'lib'
end
