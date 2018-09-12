require 'open3'
require 'fileutils'
require 'socket'
require 'capybara/spec/spec_helper'
require 'spec_helper'

describe Capybara::Webmock do
  let(:firefox_profile) do
    Capybara::Webmock.firefox_profile.instance_variable_get("@additional_prefs")
  end

  let(:chrome_args) do
    Capybara::Webmock.chrome_options[:args].first
  end

  let(:phantomjs_options) do
    Capybara::Webmock.phantomjs_options.first
  end

  it 'has a version number' do
    expect(Capybara::Webmock::VERSION).not_to be nil
  end

  describe '#chrome_args' do
    include Capybara::SpecHelper

    it 'has an proxy flag' do
      expect(chrome_args).to include 'proxy-server='
    end

    it 'has an http proxy address' do
      expect(chrome_args).to include '127.0.0.1'
    end

    it 'has an http proxy port' do
      expect(chrome_args).to include '9292'
    end

    it 'is used by the provided driver' do
      Capybara.server = :webrick
      session = Capybara::Session.new(:capybara_webmock_chrome, TestApp)

      expect do
        session.visit('/')
      end.not_to raise_error
    end
  end

  describe '#phantomjs_options' do
    it 'has an proxy flag' do
      expect(phantomjs_options).to include '--proxy='
    end

    it 'has an http proxy address' do
      expect(phantomjs_options).to include '127.0.0.1'
    end

    it 'has an http proxy port' do
      expect(phantomjs_options).to include '9292'
    end
  end

  describe '#firefox_profile' do
    it 'has an http proxy address' do
      expect(firefox_profile['network.proxy.http']).to eq '127.0.0.1'
    end

    it 'has an http proxy port' do
      expect(firefox_profile['network.proxy.http_port']).to eq 9292
    end

    it 'has an ssl proxy' do
      expect(firefox_profile['network.proxy.ssl']).to eq '127.0.0.1'
    end

    it 'has an ssl proxy port' do
      expect(firefox_profile['network.proxy.ssl_port']).to eq 9292
    end
  end

  context '.port_number' do
    it 'has a default port number' do
      expect(Capybara::Webmock.port_number).to eq 9292
    end

    context 'can change the port number for firefox' do
      before do
        Capybara::Webmock.port_number = 8877
      end

      it 'changes the http port' do
        expect(firefox_profile['network.proxy.http_port']).to eq 8877
      end

      it 'changes the ssl port' do
        expect(firefox_profile['network.proxy.ssl_port']).to eq 8877
      end
    end

    context 'can change the port number for chrome' do
      before do
        Capybara::Webmock.port_number = 9988
      end

      it 'changes the http port' do
        expect(chrome_args).to include '9988'
      end
    end
  end

  context 'starting and stopping the server' do
    let(:stdin) { instance_double(IO) }
    let(:stdout) { instance_double(IO) }

    before do
      allow(FileUtils).to receive(:mkdir_p)
      allow(Open3).to receive(:popen2e).and_return([ stdin, stdout, { pid: 1234 } ])
      allow(stdin).to receive(:close)
      allow(stdout).to receive(:read_nonblock).and_return("")
      allow(stdout).to receive(:close)

      written = []
      allow(File).to receive(:delete) { |path| written.delete(path) }
      allow(File).to receive(:write) { |path| written.push(path) }
      allow(File).to receive(:exists?) { |path| written.include?(path) }

      allow(Socket).to receive(:tcp)

      killed = []
      allow(Process).to receive(:kill) do |signal, pid|
        if signal == 0
          !killed.include?(pid)
        elsif signal == "HUP"
          killed.push(pid)
        end
      end
    end

    describe '#start' do
      it 'starts a process' do
        Capybara::Webmock.start
        expect(Open3).to have_received(:popen2e).with(
          { "PROXY_PORT_NUMBER" => "9292" },
          "rackup",
          %r{/lib/capybara/webmock/config\.ru\Z}
        )
        expect(stdin).to have_received(:close)
        expect(FileUtils).to have_received(:mkdir_p).with("tmp/pids")
        expect(File).to have_received(:write).with("tmp/pids/capybara_webmock_proxy.pid", "1234")
      end

      it 'uses a custom port' do
        Capybara::Webmock.port_number = 8873
        Capybara::Webmock.start
        expect(Open3).to have_received(:popen2e).with({ "PROXY_PORT_NUMBER" => "8873" }, anything, anything)
      end
    end

    describe '#stop' do
      it 'kills the server' do
        Capybara::Webmock.start
        expect(Process).not_to have_received(:kill)
        expect(File).not_to have_received(:delete)
        expect(stdout).not_to have_received(:close)

        Capybara::Webmock.stop
        expect(Process).to have_received(:kill).with('HUP', 1234)
        expect(File).to have_received(:delete).with("tmp/pids/capybara_webmock_proxy.pid")
        expect(stdout).to have_received(:close)
      end
    end
  end
end
