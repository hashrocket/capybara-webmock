require 'rack'
require 'capybara/webmock/proxy'

app = Capybara::Webmock::Proxy.new(Process.pid)
Rack::Handler::WEBrick.run(app, Port: ENV.fetch('PROXY_PORT_NUMBER', 9292))
