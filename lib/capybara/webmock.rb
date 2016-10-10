require 'capybara'
require 'selenium-webdriver'
require 'capybara/webmock/version'
require 'capybara/webmock/proxy'

module Capybara
  module Webmock
    class << self

      attr_accessor :port_number

      def start
        log_file   = File.join('log', 'test.log')
        gem_path   = File.dirname(__FILE__)
        proxy_file = File.join(gem_path, 'webmock', 'config.ru')
        IO.popen("PROXY_PORT_NUMBER=#{port_number} rackup #{proxy_file} >> #{log_file} 2>&1")
      end

      def stop
        if File.exist?(Capybara::Webmock::Proxy::PID_FILE)
          rack_pid = File.read(Capybara::Webmock::Proxy::PID_FILE).to_i
          Process.kill('HUP', rack_pid)
        end
      end

      def firefox_profile
        proxy_host = '127.0.0.1'
        profile = ::Selenium::WebDriver::Firefox::Profile.new
        profile["network.proxy.type"] = 1
        profile["network.proxy.http"] = proxy_host
        profile["network.proxy.http_port"] = port_number
        profile["network.proxy.ssl"] = proxy_host
        profile["network.proxy.ssl_port"] = port_number
        profile
      end

      def chrome_switches
        ["--proxy-server=127.0.0.1:#{port_number}"]
      end

    end
  end
end

Capybara::Webmock.port_number ||= 9292

Capybara.register_driver :capybara_webmock do |app|
  Capybara::Selenium::Driver.new(app, browser: :firefox, profile: Capybara::Webmock.firefox_profile)
end

Capybara.register_driver :capybara_webmock_chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome, switches: Capybara::Webmock.chrome_switches)
end
