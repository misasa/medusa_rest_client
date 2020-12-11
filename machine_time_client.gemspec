# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'machine_time_client/version'

Gem::Specification.new do |spec|
  spec.name          = "machine_time_client"
  spec.version       = MachineTimeClient::VERSION
  spec.authors       = ["Yusuke Yachi"]
  spec.email         = ["yusuke.yachi@gmail.com"]
  spec.summary       = %q{Client application for MachineTime.}
  spec.description   = %q{This is a client application for MachineTime.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency('sinatra', "~> 1.4")
  spec.add_dependency('sinatra-contrib', "~> 1.4")
  spec.add_dependency('haml', "~> 4.0")
  spec.add_runtime_dependency 'activeresource', '>= 5.1.1'
  spec.add_dependency('tepra', "~> 1.0")

  spec.add_development_dependency "bundler", "~> 2.1"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "3.3"
  spec.add_development_dependency "turnip", "~> 1.2"
  spec.add_development_dependency "rack-test", "~> 0.0"
  spec.add_development_dependency "factory_girl", "~> 4.4"
  spec.add_development_dependency "fakeweb", "~> 1.3"
  spec.add_development_dependency "fakeweb-matcher", "~> 1.2"  
end
