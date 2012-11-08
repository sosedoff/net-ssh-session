# Net::SSH::Session

A wrapper on top of `Net::SSH` and `Net::SSH::Shell` to provide a set of tools for ssh sessions

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

# Establish a connection
session = Net::SSH::Session.new(host, user, password)
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

# Capture command output
session.capture('cat /etc/lsb-release')

# File helpers
session.file_exists?('/path')
session.directory_exists?('/path')
session.read_file('/path')

# Process helpers
session.process_exists?(PID)
session.process_kill(PID)
session.last_exit_code # => 1

# Environment helpers
session.export('RAILS_ENV', 'production')
session.env('RAILS_ENV') # => production

# Execute a batch of commands
session.run_multiple(
  'git clone git@foobar.com:project.git',
  'cd project',
  'bundle install',
  'rake test'
)

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

# Close current session
session.close
```

### Running multiple commands

By default multiple command execution will not break if one of the commands fails. If you want to break the chain on the first failure, supply `:break => true` option:

```ruby
session.run_multiple(commands, :break => true)
```

To get each command result after execution, you can supply a block:

```ruby
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

## Credits

Library code was extracted and modified from multiple sources:

- Dan Sosedoff (@sosedoff)
- Mitchell Hashimoto (@mitchellh)
- Michael Klishin (@michaelklishin)
- Sven Fuchs (@svenfuchs)
- Travis-CI (@travis-ci)