require 'rack'
require 'capybara/webmock/proxy'

at_exit { Capybara::Webmock::Proxy.remove_pid }

trap('SIGHUP') {
  Capybara::Webmock::Proxy.remove_pid
  exit!
}

app = Capybara::Webmock::Proxy.new(Process.pid)
Rack::Handler::WEBrick.run(app, Port: ENV.fetch('PROXY_PORT_NUMBER', 9292))
