require 'rack/proxy'
require 'capybara/webmock'

class Capybara::Webmock::Proxy < Rack::Proxy
  ALLOWED_HOSTS = allowed_hosts = ['127.0.0.1', 'localhost', /(.*\.|\A)lvh.me/]

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

  def self.remove_pid
    File.delete(PID_FILE) if File.exist?(PID_FILE)
  end

  def rewrite_response(triplet)
    status, headers, body = triplet
    headers.delete 'transfer-encoding'
    triplet
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
