# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sidekiq_concurrency_lock/version'

Gem::Specification.new do |spec|
  spec.name          = "sidekiq_concurrency_lock"
  spec.version       = SidekiqConcurrencyLock::VERSION
  spec.authors       = ["Donald Plummer"]
  spec.email         = ["donald.plummer@gmail.com"]
  spec.description   = %q{A sidekiq middleware for preventing more than one job of a certain class from running concurrently.}
  spec.summary       = %q{Limit concurrency on a per-class basis}
  spec.homepage      = "https://github.com/crystalcommerce/sidekiq_concurrency_lock"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.0"
  spec.add_development_dependency "redis"
  spec.add_development_dependency "guard-bundler"
  spec.add_development_dependency "guard-redis"
  spec.add_development_dependency "guard-rspec"
end
