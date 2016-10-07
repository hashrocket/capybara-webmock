require 'spec_helper'
require 'capybara/webmock/proxy'

describe Capybara::Webmock::Proxy do
  it "PID_FILE to equal the correct value" do
    expect(Capybara::Webmock::Proxy::PID_FILE).to eq 'tmp/pids/capybara_webmock_proxy.pid'
  end

  context 'pid files' do
    before do
      tmp_dir = 'tmp'
      pid_dir = File.join(tmp_dir, 'pids')
      Dir.mkdir(tmp_dir) unless Dir.exist?(tmp_dir)
      Dir.mkdir(pid_dir) unless Dir.exist?(pid_dir)
    end

    it '#initialize' do
      File.write(Capybara::Webmock::Proxy::PID_FILE, '')

      expect(File.read(Capybara::Webmock::Proxy::PID_FILE)).to eq ''
      Capybara::Webmock::Proxy.new('1234567')
      expect(File.read(Capybara::Webmock::Proxy::PID_FILE)).to eq '1234567'

      File.delete(Capybara::Webmock::Proxy::PID_FILE)
    end

    it '.remove_pid' do
      File.write(Capybara::Webmock::Proxy::PID_FILE, '1234567')
      expect(File.exists?(Capybara::Webmock::Proxy::PID_FILE)).to be
      Capybara::Webmock::Proxy.remove_pid
      expect(File.exists?(Capybara::Webmock::Proxy::PID_FILE)).to_not be
    end
  end
end
