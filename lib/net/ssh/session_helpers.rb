require 'timeout'

module Net
  module SSH
    module SessionHelpers
      # Execute command with sudo
      # @param [String] command string
      # @param [Hash] execution options
      # @return [SessionCommand]
      def sudo(command, options={})
        run("sudo #{command}", options)
      end

      # Swith current directory
      # @param path [String] directory path
      # @return [Boolean] execution result
      def chdir(path)
        run("cd #{path}").success?
      end

      # Get current directory
      # @return [String]
      def pwd
        capture("pwd")
      end

      # Execute command and capture any output
      # @param command [String] command to execute
      # @return [String] execution result
      def capture(command)
        run(command).output.strip
      end

      # Read remote file contents
      # @path [String] file path
      # @return [String] file contents
      def read_file(path)
        result = run("cat #{path}")
        result.success? ? result.output : ''
      end

      # Check if remote directory exists
      # @param path [String] directory path
      # @return [Boolean] execution result
      def directory_exists?(path)
        run("test -d #{path}").success?
      end

      # Check if remote file exists
      # @param [String] file path
      # @return [Boolean] execution result
      def file_exists?(path)
        run("test -f #{path}").success?
      end

      # Check if a symbilic link exists
      # @param [String] file path
      # @return [Boolean]
      def symlink_exists?(path)
        run("test -h #{path}").success?
      end

      # Check if process with PID is running
      # @param pid [String] process id
      # @return [Boolean] execution result
      def process_exists?(pid)
        run("ps -p #{pid}").success?
      end

      # Kill a process with the signal
      # @param pid [String] process id
      # @param signal [String] signal to send
      # @return [Boolean] exection result
      def kill_process(pid, signal='SIGTERM')
        run("kill -#{signal} #{pid}")
        process_exists?(pid)
      end

      # Check if user exists
      # @param [String] username
      # @return [Boolean]
      def has_user?(name, options={})
        run("id #{name}").success?
      end

      # Check if group exists
      # @param [String] group name
      # @return [Boolean]
      def has_group?(name)
        run("id -g #{name}").success?
      end

      # Export an environment variable
      # @param key [String] variable name
      # @param value [String] variable value
      # @return [Boolean] execution result
      def export(key, value)
        run("export #{key}=#{value}").success?
      end

      # Export environment vars from hash
      # @param data [Hash]
      # @return [Boolean] execution result
      def export_hash(data={})
        data.each_pair do |k, v|
          export(k, v)
        end
      end

      # Get an environment variable
      # @param key [String] variable name
      # @return [String] variable value
      def env(key)
        capture("echo $#{key}")
      end

      # Get last executed command exit code
      # @return [Integer] exit code
      def last_exit_code
        Integer(capture("echo $?"))
      end

      # Set a timeout context for execution
      # @param time [Integer] max time for execution in seconds
      # @param block [Block] block to execute
      def with_timeout(time, &block)
        Timeout.timeout(time) do
          block.call(self)
        end
      end
    end
  end
end