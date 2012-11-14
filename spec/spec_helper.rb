$:.unshift File.expand_path("../..", __FILE__)

require 'net/ssh/session'

def fixture_path(filename=nil)
  path = File.expand_path("../fixtures", __FILE__)
  filename.nil? ? path : File.join(path, filename)
end

def fixture(file)
  File.read(File.join(fixture_path, file))
end

def fake_run(command, output, exit_code=0, duration=0)
  Net::SSH::SessionCommand.new(command, output, exit_code, duration)
end