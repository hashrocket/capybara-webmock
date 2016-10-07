require 'rack'
require 'capybara/webmock/proxy'

at_exit { Capybara::Webmock::Proxy.remove_pid }

trap('SIGHUP') {
  Capybara::Webmock::Proxy.remove_pid
  exit!
}

app = Capybara::Webmock::Proxy.new(Process.pid)
Rack::Handler::WEBrick.run app, { Port: 9292 }
