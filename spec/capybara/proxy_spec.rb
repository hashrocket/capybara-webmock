require 'spec_helper'
require 'ostruct'

describe Capybara::Webmock::Proxy do

  it "PID_FILE to equal the correct value" do
    expect(Capybara::Webmock::Proxy::PID_FILE).to eq 'tmp/pids/capybara_webmock_proxy.pid'
  end

  context 'pid files' do
    before do
      Capybara::Webmock::Proxy.new('')
    end

    after do
      if File.exists?(Capybara::Webmock::Proxy::PID_FILE)
        File.delete(Capybara::Webmock::Proxy::PID_FILE)
      end
    end

    it '#initialize' do
      expect {
        Capybara::Webmock::Proxy.new('1234567')
      }.to change {
        File.read(Capybara::Webmock::Proxy::PID_FILE)
      }.from('').to('1234567')
    end

    it '.remove_pid' do
      expect {
        Capybara::Webmock::Proxy.remove_pid
      }.to change {
        File.exists?(Capybara::Webmock::Proxy::PID_FILE)
      }.from(true).to(false)
    end
  end

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

    it 'returns an empty response when unknown domain' do
      env = new_env("notlvh.me")
      expect(proxy.perform_request(env)).to eq ["200", {"Content-Type"=>"text/html"}, [""]]
    end

    context 'with allowed hosts' do
      before do
        stubbed_http = instance_double(Net::HTTP)
        stubbed_response = OpenStruct.new(code: '200', headers: [], body: 'good response')
        allow(stubbed_http).to receive(:read_timeout=)
        allow(stubbed_http).to receive(:start).and_return(stubbed_response)
        expect(Net::HTTP).to receive(:new).and_return(stubbed_http)
      end

      %w{lvh.me sub.lvh.me localhost 127.0.0.1}.each do |host|
        it "allows #{host}" do
          env = new_env(host)
          expect(proxy.perform_request(env)).to eq ["200", [], ["good response"]]
        end
      end
    end
  end
end
