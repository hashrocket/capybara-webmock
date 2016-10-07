require 'capybara'
require 'capybara/webmock/version'

module Capybara
  module Webmock
    def start
      log_file   = File.expand_path('log', 'test.log')
      proxy_file = Dir.join('lib', 'capybara', 'webmock', 'proxy.rb')
      IO.popen("ruby #{proxy_file} >> #{log_file} 2>&1")
    end

    def stop
      if rack_pid = File.read(Rails.root.join('tmp', 'rack.pid')).to_i
        Process.kill('HUP', rack_pid)
      end
    end
  end
end

Capybara.register_driver :selenium_proxy do |app|
  profile = Selenium::WebDriver::Firefox::Profile.new
  profile["network.proxy.type"] = 1
  profile["network.proxy.http"] = '127.0.0.1'
  profile["network.proxy.http_port"] = 9292
  Capybara::Selenium::Driver.new(app, browser: :firefox, profile: profile)
end
