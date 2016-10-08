require 'simplecov'

if ENV['CIRCLE_ARTIFACTS']
  dir = File.join(ENV['CIRCLE_ARTIFACTS'], "coverage")
  SimpleCov.coverage_dir(dir)
end

SimpleCov.start

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "capybara/webmock"
