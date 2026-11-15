source 'https://rubygems.org'

gemspec

# FactoryBot 6.4 uses argument forwarding despite allowing Ruby 2.6 in its metadata.
gem 'factory_bot', '~> 6.2.1' if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.7')
