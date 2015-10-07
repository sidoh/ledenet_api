# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'ledenet_api'

Gem::Specification.new do |spec|
  spec.name          = "ledenet_api"
  spec.version       = LEDENETApi::VERSION
  spec.authors       = ["Christopher Mullins"]
  spec.email         = ["chris@sidoh.org"]

  spec.summary       = %q{An API to control the LEDENET Magic UFO LED WiFi Controller}
  spec.homepage      = "http://www.github.com/sidoh/ledenet_api"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
