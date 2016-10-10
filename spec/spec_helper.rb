require 'simplecov'

if ENV['CIRCLE_ARTIFACTS']
  dir = File.join(ENV['CIRCLE_ARTIFACTS'], "coverage")
  SimpleCov.coverage_dir(dir)
end

SimpleCov.start

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "capybara/webmock"

RSpec.configure do |config|
  config.after(:each) do
    Capybara::Webmock.port_number = 9292
    log_file = File.join(Dir.pwd, 'log', 'test.log')
    File.delete(log_file) if File.exist?(log_file)
  end
end
