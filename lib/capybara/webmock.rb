require 'open3'
require 'fileutils'
require 'socket'
require 'capybara'
require 'selenium-webdriver'
require 'capybara/webmock/version'
require 'capybara/webmock/proxy'
require 'capybara/webmock/proxied_request'

module Capybara
  module Webmock
    class << self
      attr_accessor :port_number, :pid_file, :kill_timeout, :start_timeout

      def start
        if @pid.nil?
          kill_old_process
          gem_path   = File.dirname(__FILE__)
          proxy_file = File.join(gem_path, 'webmock', 'config.ru')
          stdin, stdout, wait_thr = Open3.popen2e({ "PROXY_PORT_NUMBER" => port_number.to_s }, "rackup", proxy_file)
          stdin.close
          @stdout = stdout
          @pid = wait_thr[:pid]
          write_pid_file
          wait_for_proxy_start
        end

        reset
      end

      def reset
        get_output_nonblocking
        @output_buf = ""
      end

      def proxied_requests
        @output_buf += get_output_nonblocking

        matches = @output_buf.sub(/\n[^\n]+\z/, '').split("\n").map do |line|
          match = /\A(.+) -> (.+)\Z/.match(line)
          next nil unless match
          match.captures
        end

        matches.compact.map{ |raw_referrer, raw_uri| ProxiedRequest.new(raw_referrer, raw_uri) }
      end

      def stop
        return if @pid.nil?

        @stdout.close
        kill_process(@pid)
        remove_pid_file

        @pid = nil
        @stdout = nil
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

      def chrome_options
        ::Selenium::WebDriver::Chrome::Options.new.tap do |options|
          options.add_argument "--proxy-server=127.0.0.1:#{port_number}"
        end
      end

      def chrome_headless_options
        chrome_options.tap { |options| options.headless! }
      end

      def phantomjs_options
        ["--proxy=127.0.0.1:#{port_number}"]
      end

      private

      def wait_for_proxy_start
        connected = false
        (1..start_timeout).each do
          begin
            Socket.tcp("127.0.0.1", port_number, connect_timeout: 1) {}
            connected = true
            break
          rescue => e
            sleep 1
          end
        end

        unless connected
          raise "Unable to connect to capybara-webmock proxy on #{port_number}"
        end
      end

      def get_output_nonblocking
        buf = ""

        while true
          begin
            output = @stdout.read_nonblock(1024)
            break if output == ""
            buf += output
          rescue IO::WaitReadable
            break
          end
        end

        buf
      end

      def kill_old_process
        return unless File.exists?(pid_file)
        old_pid = File.read(pid_file).to_i
        kill_process(old_pid) if old_pid > 1
        remove_pid_file
      end

      def kill_process(pid)
        Process.kill('HUP', pid) if process_alive?(pid)

        (1..kill_timeout).each do
          sleep(1) if process_alive?(pid)
        end

        Process.kill('KILL', pid) if process_alive?(pid)

        (1..kill_timeout).each do
          sleep(1) if process_alive?(pid)
        end

        if process_alive?(pid)
          raise "Unable to kill capybara-webmock process with PID #{pid}"
        end
      end

      def process_alive?(pid)
        !!Process.kill(0, pid) rescue false
      end

      def write_pid_file
        raise "Pid file #{pid_file} already exists" if File.exists?(pid_file)
        FileUtils.mkdir_p(File.dirname(pid_file))
        File.write(pid_file, @pid.to_s)
      end

      def remove_pid_file
        File.delete(pid_file) if File.exists?(pid_file)
      end
    end
  end
end

Capybara::Webmock.port_number ||= 9292
Capybara::Webmock.pid_file ||= File.join('tmp', 'pids', 'capybara_webmock_proxy.pid')
Capybara::Webmock.kill_timeout ||= 5
Capybara::Webmock.start_timeout ||= 30

Capybara.register_driver :capybara_webmock do |app|
  Capybara::Selenium::Driver.new(app, browser: :firefox, profile: Capybara::Webmock.firefox_profile)
end

Capybara.register_driver :capybara_webmock_chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: Capybara::Webmock.chrome_options)
end

Capybara.register_driver :capybara_webmock_chrome_headless do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: Capybara::Webmock.chrome_headless_options)
end

Capybara.register_driver :capybara_webmock_poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, phantomjs_options: Capybara::Webmock.phantomjs_options)
end
