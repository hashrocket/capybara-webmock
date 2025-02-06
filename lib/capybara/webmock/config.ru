require 'rack'
require 'capybara/webmock/proxy'

app = Capybara::Webmock::Proxy.new(Process.pid)
rack_handler = defined?(Rackup::Handler::WEBrick) ? Rackup::Handler::WEBrick : Rack::Handler::WEBrick
rack_handler.run(app, Port: ENV.fetch('CAPYBARA_WEBMOCK_PROXY_PORT_NUMBER', 9292))
