$:.unshift File.expand_path("../..", __FILE__)

RSpec.configure do |conf|
  conf.include Rack::Test::Methods
end

def fixture_path(filename=nil)
  path = File.expand_path("../fixtures", __FILE__)
  filename.nil? ? path : File.join(path, filename)
end

def fixture(file)
  File.read(File.join(fixture_path, file))
end