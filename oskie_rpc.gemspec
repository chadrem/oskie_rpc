# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'oskie_rpc/version'

Gem::Specification.new do |spec|
  spec.name          = "oskie_rpc"
  spec.version       = OskieRpc::VERSION
  spec.authors       = ["Chad Remesch"]
  spec.email         = ["chad@remesch.com"]

  spec.summary       = %q{Simple easy to use transport agnostic RPC gem.}
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "filter_chain", "~> 0.2"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest"
end
