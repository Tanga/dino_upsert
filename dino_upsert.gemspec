# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dino_upsert/version'

Gem::Specification.new do |spec|
  spec.name          = "dino_upsert"
  spec.version       = DinoUpsert::VERSION
  spec.authors       = ["Joe Van Dyk"]
  spec.email         = ["joe@tanga.com"]

  spec.summary       = %q{Upsert stuff}
  spec.homepage      = "https://github.com/tanga/dino_upsert"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_dependency "activerecord", ">= 3"
  spec.add_dependency "pg"
end
