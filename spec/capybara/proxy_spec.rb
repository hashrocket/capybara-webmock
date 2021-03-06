require 'spec_helper'
require 'ostruct'

describe Capybara::Webmock::Proxy do
  context '#perform_requests' do
    def new_env(host)
      {
        "REQUEST_METHOD" => "GET",
        "REQUEST_URI" => "http://#{host}",
        "HTTP_HOST" => host,
        "REQUEST_PATH" => "/index.html"
      }
    end

    let(:proxy) { Capybara::Webmock::Proxy.new('123456') }

    let(:expected_headers) { {
      'Content-Type' => 'text/html',
      'Access-Control-Allow-Origin' => '*',
      'Access-Control-Allow-Methods' => '*',
      'Access-Control-Allow-Headers' => '*'
    } }

    before do
      allow_any_instance_of(Rack::Proxy).to receive(:perform_request).and_return(['400', {foo: :bar}, ['baz']])
    end

    it 'returns an empty response when unknown host' do
      env = new_env("notlvh.me")
      expect(proxy.perform_request(env)).to eq ["200", expected_headers, [""]]
    end

    %w{lvh.me sub.lvh.me localhost 127.0.0.1}.each do |host|
      it "allows known #{host}" do
        env = new_env(host)
        expect(proxy.perform_request(env)).to eq(['400', {foo: :bar}, ['baz']])
      end
    end

    %w{lvh.me sub.lvh.me localhost 127.0.0.1 example.com sub.example.com}.each do |host|
      it "allows extra host overrides #{host}" do
        allow(ENV).to receive(:fetch).with("CAPYBARA_WEBMOCK_ADDED_HOSTS", "").and_return("sub.example.com|example.com")
        env = new_env(host)
        expect(proxy.perform_request(env)).to eq(['400', {foo: :bar}, ['baz']])
      end
    end
  end
end
