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

## Credits

Library code was extracted and modified from multiple sources:

- Dan Sosedoff (@sosedoff)
- Mitchell Hashimoto (@mitchellh)
- Michael Klishin (@michaelklishin)
- Sven Fuchs (@svenfuchs)
- Travis-CI (@travis-ci)