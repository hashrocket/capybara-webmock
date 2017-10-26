require 'rack/proxy'
require 'capybara/webmock'

class Capybara::Webmock::Proxy < Rack::Proxy
  ALLOWED_HOSTS = allowed_hosts = ['127.0.0.1', 'localhost', %r{(.*\.|\A)lvh.me}]

  def perform_request(env)
    request = Rack::Request.new(env)

    if allowed_host?(request.host)
      super(env)
    else
      ['200', {'Content-Type' => 'text/html'}, ['']]
    end
  end

  private

  def allowed_host?(host)
    ALLOWED_HOSTS.any? do |allowed_host|
      case allowed_host
      when Regexp
        allowed_host =~ host
      when String
        allowed_host == host
      end
    end
  end
end
