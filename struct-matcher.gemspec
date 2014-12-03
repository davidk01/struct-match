# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'struct-matcher/match/version'

Gem::Specification.new do |spec|
  spec.name          = "struct-matcher"
  spec.version       = Match::VERSION
  spec.authors       = ["david karapetyan"]
  spec.email         = ["dkarapetyan@scriptcrafty.com"]
  spec.description   = %q{Basic pattern matching for struct types.}
  spec.summary       = %q{Mini-dsl for generating validators and pattern matchers for struct types.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "pry"
end
