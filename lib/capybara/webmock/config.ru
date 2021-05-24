require 'rack'
require 'capybara/webmock/proxy'

app = Capybara::Webmock::Proxy.new(Process.pid)
Rack::Handler::WEBrick.run(app, Port: ENV.fetch('CAPYBARA_WEBMOCK_PROXY_PORT_NUMBER', 9292))
