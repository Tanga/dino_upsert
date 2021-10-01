# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dino_utils/version'

Gem::Specification.new do |spec|
  spec.name          = "dino_utils"
  spec.version       = DinoUtils::VERSION
  spec.authors       = ["Joe Van Dyk"]
  spec.email         = ["joe@tanga.com"]

  spec.summary       = %q{Dino stuff}
  spec.homepage      = "https://github.com/tanga/dino_utils"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_dependency "activerecord"
  spec.add_dependency "hashie", ">= 0"
  spec.add_dependency "faraday"
  spec.add_dependency "faraday_middleware"
  spec.add_dependency "faraday-conductivity"
  spec.add_dependency "net-http-persistent", "~> 2"
  spec.add_dependency "pg"
end
