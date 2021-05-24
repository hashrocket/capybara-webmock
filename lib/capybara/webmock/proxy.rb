require 'rack/proxy'
require 'capybara/webmock'

class Capybara::Webmock::Proxy < Rack::Proxy
  DEFAULT_ALLOWED_HOSTS = ['127.0.0.1', 'localhost', /(.*\.|\A)lvh.me/]

  def call(env)
    @streaming = true
    super
  end

  def perform_request(env)
    request = Rack::Request.new(env)

    if allowed_host?(request.host)
      super(env)
    else
      headers = {
        'Content-Type' => 'text/html',
        'Access-Control-Allow-Origin' => '*',
        'Access-Control-Allow-Methods' => '*',
        'Access-Control-Allow-Headers' => '*'
      }
      ['200', headers, ['']]
    end
  end

  private

  def allowed_hosts
    DEFAULT_ALLOWED_HOSTS + ENV.fetch('__CAPYBARA_WEBMOCK_ADDED_HOSTS', "").split(Capybara::Webmock::SEPARATOR)
  end

  def allowed_host?(host)
    allowed_hosts.any? do |allowed_host|
      case allowed_host
      when Regexp
        allowed_host =~ host
      when String
        allowed_host == host
      end
    end
  end
end
