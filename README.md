# Net::SSH::Session

A wrapper on top of `Net::SSH` and `Net::SSH::Shell` to provide a set of tools for ssh sessions

[![Build Status](https://travis-ci.org/sosedoff/net-ssh-session.png?branch=master)](https://travis-ci.org/sosedoff/net-ssh-session)

## Install

Install with rubygems:

```
gem install net-ssh-session
```

Install with bundler:

```
gem 'net-ssh-session', :github => 'sosedoff/net-ssh-session'
```

## Usage

Basic usage:

```ruby
require 'net/ssh/session'

# Initialize a new connection
session = Net::SSH::Session.new(host, user, password)

# Initialize connection on a different SSH port
session = Net::SSH::Session.new(host, user, password, :port => 5000)

# Connect to server
session.open

# If you want to set a connection timeout in seconds
# it will raise Timeout::Error 
session.open(10)

# Execute a remote command
result = session.run("free -m")

# Net::SSH::SessionCommand helpers
result.success?  # => true
result.failure?  # => false
result.exit_code # => 0
result.output    # => command output text
result.duration  # => execution time, seconds

# Capture command output
session.capture('cat /etc/lsb-release')

# File helpers
session.file_exists?('/path')
session.directory_exists?('/path')
session.symlink_exists?('/path')
session.read_file('/path')

# Process helpers
session.process_exists?(PID)
session.kill_process(PID) # => true
session.kill_process(PID, 'SIGINT') # => false
session.last_exit_code # => 1

# Environment helpers
session.env('RAILS_ENV') # => production
session.export('RAILS_ENV', 'production')
session.export_hash(
  'RAILS_ENV' => 'test',
  'RACK_ENV'  => 'test'
)

# Execute a batch of commands
session.run_multiple(
  'git clone git@foobar.com:project.git',
  'cd project',
  'bundle install',
  'rake test'
)

# Execute by calling a method
session.ping("-c 5", "google.com")
session.df('-h')

# Execute as sudo
session.sudo("whoami")

# Execute with time limit (10s)
begin
  session.with_timeout(10) do
    session.run('some long job')
  end
rescue Timeout::Error
  puts "Operation took too long :("
end

# Execute a long command and show ongoing process
session.run("rake test") do |str|
  puts str
end

# Get history, returns an array with Net::SSH::SessionCommand objects
session.history.each do |cmd|
  puts cmd.to_s # => I, [2012-11-08T00:10:48.229986 #51878]  INFO -- : [bundle install --path .bundle] => 10, 35 bytes
  if cmd.success?
    # do your thing
  end
end

# Close current session
session.close
```

## Advanced Usage

### Running multiple commands

By default multiple command execution will not break if one of the commands fails. If you want to break the chain on the first failure, supply `:break => true` option:

```ruby
session.run_multiple(commands, :break => true)
```

To get each command result after execution, you can supply a block:

```ruby
commands = ["mkdir /tmp", "echo test > /tmp/file", "rm -rf /tmp"]

session.run_multiple(commands) do |cmd|
  puts "Original command: #{cmd.command}"
  puts "Exit code: #{cmd.exit_code}"
  puts "Output: #{cmd.output}"
end
```

### Using session logger

If you want to log command execution for the whole session you can assign a logger:

```ruby
require 'logger'
require 'net/ssh/session'

s = Net::SSH::Session.new(host, user, password)
s.logger = Logger.new(STDOUT)
s.open

s.run("cd /tmp")
s.run("git clone git://github.com/sosedoff/net-ssh-session.git")
s.run("bundle install --path .bundle")

s.close
```

Since the logger is set to write to `STDOUT` you'll see something like this:

```
I, [2012-11-08T00:10:47.605916 #51878]  INFO -- : [cd /tmp] => 0, 0 bytes
I, [2012-11-08T00:10:48.038294 #51878]  INFO -- : [git clone git://github.com/sosedoff/net-ssh-session.git] => 0, 7795 bytes
I, [2012-11-08T00:10:48.229986 #51878]  INFO -- : [bundle install --path .bundle] => 10, 35 bytes
```

### Execution history

By default each session command (`Net::SSH::SessionCommand`) will be recorded in 
session history. Example how to skip history tracking:

```ruby
require 'net/ssh/session'

s = Net::SSH::Session.new(host, user, password)
s.open

# Run commands with no history
s.run("export RAILS_ENV=test", :history => false)
r.run("mysqlcheck --repair mysql proc -u root", :history => false)

# Rest will be recorded
s.run("git clone git://github.com/sosedoff/net-ssh-session.git")
s.run("bundler install --path .")

s.close
```

You can also disable history for the whole session:

```ruby
Net::SSH::Session.new(host, user, password, :history => false)
```

## Execute any command with timeout

To enable session-wide command execution timeout, pass an extra option:

```ruby
session = Net::SSH::Session.new(host, user, password, :timeout => 10)
```

This will limit any command execution time to 10 seconds. Error `Timeout::Error`
will be raised when timeout is exceeded.

## License

The MIT License (MIT)

Copyright (c) 2012-2014 Dan Sosedoff, <dan.sosedoff@gmail.com>