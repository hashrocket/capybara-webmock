# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capybara/webmock/version'

Gem::Specification.new do |spec|
  spec.name          = 'capybara-webmock'
  spec.version       = Capybara::Webmock::VERSION
  spec.authors       = ['Jake Worth', 'Dillon Hafer']
  spec.email         = ['dev@hashrocket.com']

  spec.summary       = %q{Mock external requests}
  spec.description   = %q{Mock external requests for Capybara JavaScript drivers}
  spec.homepage      = 'https://github.com/hashrocket/capybara-webmock'
  spec.license       = 'MIT'

  spec.required_ruby_version     = ">= 2.0.0"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.require_paths = ["lib"]

  spec.add_dependency "capybara", ">= 2.4", "< 4"
  spec.add_dependency "rack", ">= 1.4"
  spec.add_dependency "rack-proxy", ">= 0.6.0"
  spec.add_dependency "selenium-webdriver", "~> 3.0"

  spec.add_development_dependency "bundler", ">= 1.13"
  spec.add_development_dependency "pry", "~> 0.10.4"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "sinatra"
  spec.add_development_dependency "launchy"
end
