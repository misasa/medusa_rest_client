# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'medusa_rest_client/version'

Gem::Specification.new do |spec|
  spec.name          = "medusa_rest_client"
  spec.version       = MedusaRestClient::VERSION
  spec.authors       = ["Yusuke Yachi"]
  spec.email         = ["yyachi@misasa.okayama-u.ac.jp"]
  spec.summary       = %q{REST client for accessing Medusa Web API}
  spec.description   = %q{This rubygem helps development of medusa clients.}
  spec.homepage      = "http://devel.misasa.okayama-u.ac.jp/gitlab/gems/medusa_rest_client"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

#  spec.add_runtime_dependency 'bigdecimal', "~> 1.4"
  spec.add_runtime_dependency 'activeresource', '~> 5.1'
  spec.add_runtime_dependency 'rails-observers'
  spec.add_runtime_dependency 'pry', '~> 0.9'
  spec.add_runtime_dependency 'gli', '~> 2.12'
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.1.0"
  spec.add_development_dependency "turnip", "1.2.1"

  spec.add_development_dependency "factory_girl", "~> 4.4"
  spec.add_development_dependency "fakeweb", "~> 1.3"
  spec.add_development_dependency "fakeweb-matcher", "~> 1.2"
  spec.add_development_dependency "geminabox", ">= 0.13.10"
  spec.add_development_dependency "webmock", "~> 1.20.4"
#  spec.add_development_dependency "simplecov-rcov", "~> 0.2.3"
#  spec.add_development_dependency "rspec_junit_formatter", "~> 0.2.0"  
end
