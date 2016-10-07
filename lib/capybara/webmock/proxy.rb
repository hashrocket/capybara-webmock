require 'rack'
require 'rack/proxy'

class Capybara::Webmock::Proxy < Rack::Proxy
  def perform_request(env)
    request = Rack::Request.new(env)
    if request.host =~ %r{.*\.lvh.me}
      super(env)
    else
      ['200', {'Content-Type' => 'text/html'}, ['ok']]
    end
  end
end

def remove_proxy_pid_file
  File.delete('tmp/rack.pid') if File.exists?('tmp/rack.pid')
end

File.write('tmp/rack.pid', Process.pid)

at_exit { remove_proxy_pid_file }

trap("SIGHUP") do
  remove_proxy_pid_file
  exit!
end

app = Capybara::Webmock::Proxy.new
Rack::Handler::WEBrick.run app, { Port: 9292 }
