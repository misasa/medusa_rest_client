# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'medusa_rest_client/version'

Gem::Specification.new do |spec|
  spec.name          = "medusa_rest_client"
  spec.version       = MedusaRestClient::VERSION
  spec.authors       = ["Yusuke Yachi"]
  spec.email         = ["yyachi@misasa.okayama-u.ac.jp"]
  spec.summary       = "Ruby client for the Medusa REST API"
  spec.description   = "Access Medusa records, upload attachments, and manage associations from Ruby or the command line."
  spec.homepage      = "https://github.com/misasa/medusa_rest_client"
  spec.license       = "GPL-3.0-or-later"

  spec.required_ruby_version = ">= 2.5.0"
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["bug_tracker_uri"] = "#{spec.homepage}/issues"

  spec.files         = %w[LICENSE.txt README.md bin/medusa] + Dir["lib/**/*.rb"].sort
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'activeresource', '>= 5.1', '< 7'
  spec.add_dependency 'logger', '>= 1.4', '< 2'
  spec.add_dependency 'base64', '>= 0.1', '< 1'
  spec.add_dependency 'bigdecimal', '>= 1.4', '< 5'
  spec.add_dependency 'pry', '>= 0.13', '< 1'

  spec.add_development_dependency 'bundler', '>= 2.3', '< 5'
  spec.add_development_dependency 'rake', '>= 12.3', '< 14'
  spec.add_development_dependency 'rspec', '~> 3.13'
  spec.add_development_dependency 'factory_bot', '>= 6.2', '< 7'
  spec.add_development_dependency 'observer', '~> 0.1'
  spec.add_development_dependency 'webmock', '~> 3.23'
end
