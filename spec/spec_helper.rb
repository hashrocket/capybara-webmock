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
    Capybara::Webmock.instance_variables.each do |var|
      Capybara::Webmock.send(:remove_instance_variable, var)
    end

    Capybara::Webmock.port_number = 9292
    Capybara::Webmock.pid_file = File.join('tmp', 'pids', 'capybara_webmock_proxy.pid')
    Capybara::Webmock.kill_timeout = 5
  end
end
