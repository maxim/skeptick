# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'skeptick/version'

Gem::Specification.new do |gem|
  gem.name          = "skeptick"
  gem.version       = Skeptick::VERSION
  gem.authors       = ["Maxim Chernyak"]
  gem.email         = ["max@bitsonnet.com"]
  gem.description   = %q{Thin ImageMagick DSL with smart command composition}
  gem.summary       = %q{Skeptick doesn't believe in Magick}
  gem.homepage      = "https://github.com/maxim/skeptick"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency 'posix-spawn', '~> 0.3.6'
  gem.add_development_dependency 'rake', '>= 0.9.2'
  gem.add_development_dependency 'pry'
end
