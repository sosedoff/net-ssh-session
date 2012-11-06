# Net::SSH::Session

A wrapper on top of Net::SSH and Net::SSH::Shell to provide a set of tools for ssh sessions

## Usage

Basic usage:

```ruby
require 'net/ssh/session'

# Establish a connection
session = Net::SSH::Session.new(host, user, password)
session.open

# Execute a remote command
result = session.run("free -m")

result.success? # => true
result.failure? # => false
result.output # Get command output

# Capture command output
result.capture('cat /etc/lsb-release')

# File helpers
session.file_exists?('/path')
session.directory_exists?('/path')

# Execute a batch of commands
session.run_multiple(
  'git clone git@foobar.com:project.git',
  'cd project',
  'bundle install'
  'rake test'
)

session.close
```

### Running multiple commands

By default multiple command execution will not break if one of the commands fails. If you want to break the chain on the first failure, supply `:break => false` option:

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