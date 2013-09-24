require File.expand_path('../lib/net-ssh-session/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = "net-ssh-session"
  s.version     = Net::SSH::Session::VERSION
  s.summary     = "Shell session for Net::SSH connections"
  s.description = "Shell interface with helper methods to work with Net::SSH connections"
  s.homepage    = "https://github.com/sosedoff/net-ssh-session"
  s.authors     = ["Dan Sosedoff"]
  s.email       = ["dan.sosedoff@gmail.com"]
  
  s.add_development_dependency 'rake',      '~> 10'
  s.add_development_dependency 'rspec',     '~> 2.14'
  s.add_development_dependency 'simplecov', '~> 0.7'

  s.add_dependency 'net-ssh', '~> 2.6'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{|f| File.basename(f)}
  s.require_paths = ["lib"]
end
