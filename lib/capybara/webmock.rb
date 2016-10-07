require 'capybara'
require 'capybara/webmock/version'
require 'capybara/webmock/proxy'

module Capybara
  module Webmock

    class << self

      def start
        log_file   = File.join('log', 'test.log')
        proxy_file = File.join('lib', 'capybara', 'webmock', 'config.ru')
        IO.popen("ruby #{proxy_file} >> #{log_file} 2>&1")
      end

      def stop
        if rack_pid = File.read(Capybara::Webmock::Proxy::PID_FILE).to_i
          Process.kill('HUP', rack_pid)
        end
      end

    end
  end
end

Capybara.register_driver :capybara_webmock do |app|
  profile = Selenium::WebDriver::Firefox::Profile.new
  profile["network.proxy.type"] = 1
  profile["network.proxy.http"] = '127.0.0.1'
  profile["network.proxy.http_port"] = 9292
  Capybara::Selenium::Driver.new(app, browser: :firefox, profile: profile)
end
