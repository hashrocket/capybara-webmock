require 'rack/proxy'
require 'capybara/webmock'

class Capybara::Webmock::Proxy < Rack::Proxy
  PID_FILE = File.join('tmp', 'pids', 'capybara_webmock_proxy.pid')

  def initialize(pid)
    write_pid(pid)
  end

  def perform_request(env)
    request = Rack::Request.new(env)
    if request.host =~ %r{.*\.lvh.me}
      super(env)
    else
      ['200', {'Content-Type' => 'text/html'}, ['']]
    end
  end

  def self.remove_pid
    File.delete(PID_FILE) if File.exists?(PID_FILE)
  end

  private

  def write_pid(pid)
    tmp_dir = 'tmp'
    pid_dir = File.join(tmp_dir, 'pids')
    Dir.mkdir(tmp_dir) unless Dir.exist?(tmp_dir)
    Dir.mkdir(pid_dir) unless Dir.exist?(pid_dir)
    File.write(PID_FILE, pid)
  end
end
