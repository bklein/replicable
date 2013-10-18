# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'replicable/version'

Gem::Specification.new do |spec|
  spec.name          = "replicable"
  spec.version       = Replicable::VERSION
  spec.authors       = ["Ben Klein"]
  spec.email         = ["bk.romulox@gmail.com"]
  spec.description   = %q{Allows models to replicate themselves}
  spec.summary       = %q{Provides easy JSON import/export interface for ActiveRecord}
  spec.homepage      = "http://www.hirebenklein.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "sqlite3"
end
