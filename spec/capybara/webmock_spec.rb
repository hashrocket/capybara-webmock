require 'spec_helper'

describe Capybara::Webmock do
  let(:firefox_profile) do
    Capybara::Webmock.firefox_profile.instance_variable_get("@additional_prefs")
  end

  let(:chrome_switches) do
    Capybara::Webmock.chrome_switches.first
  end

  it 'has a version number' do
    expect(Capybara::Webmock::VERSION).not_to be nil
  end

  describe '#chrome_switches' do
    it 'has an http proxy address' do
      expect(chrome_switches).to include '127.0.0.1'
    end

    it 'has an http proxy port' do
      expect(chrome_switches).to include '9292'
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
        expect(chrome_switches).to include '9988'
      end
    end
  end

  describe '#start' do
    before do
      allow(IO).to receive(:popen)
    end

    def new_popen_regex(port: 9292)
      /PROXY_PORT_NUMBER=#{port} rackup .*lib\/capybara\/webmock\/config\.ru >> log\/test.log 2>&1/
    end

    it 'starts a process' do
      popen_args_regex = new_popen_regex
      Capybara::Webmock.start
      expect(IO).to have_received(:popen).with(popen_args_regex)
    end

    it 'uses a custom port' do
      Capybara::Webmock.port_number = 8873

      popen_args_regex = new_popen_regex(port: 8873)
      Capybara::Webmock.start
      expect(IO).to have_received(:popen).with(popen_args_regex)
    end
  end

  describe '#stop' do
    before do
      allow(IO).to receive(:popen).and_return(OpenStruct.new(pid: 42))
      allow(Process).to receive(:kill)
      Capybara::Webmock::Proxy.new '42'
    end

    after do
      Capybara::Webmock::Proxy.remove_pid
    end

    it 'kills the server' do
      pid = Capybara::Webmock.start.pid
      Capybara::Webmock.stop
      expect(Process).to have_received(:kill).with('HUP', 42)
    end
  end
end
