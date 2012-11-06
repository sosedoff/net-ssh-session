module Net
  module SSH
    module SessionHelpers
      # Execute command and capture any output
      # @param command [String] command to execute
      # @return [String] execution result
      def capture(command)
        run(command).output
      end

      # Read remote file contents
      # @path [String] file path
      # @return [String] file contents
      def read_file(path)
        run("cat #{path}")
      end

      # Check if remote directory exists
      # @param path [String] directory path
      # @return [Boolean] execution result
      def directory_exists?(path)
        run("test -d #{path}").success?
      end

      # Check if remote file exists
      # @param path [String] file path
      # @return [Boolean] execution result
      def file_exists?(path)
        run("test -f #{path}").success?
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
      def process_kill(pid, signal='SIGTERM')
        run("kill -#{signal} #{pid}").sucess?
      end

      # Export an environment variable
      # @param key [String] variable name
      # @param value [String] variable value
      # @return [Boolean] execution result
      def export(key, value)
        run("export #{key}=#{value}").sucess?
      end

      # Get an environment variable
      # @param key [String] variable name
      # @return [String] variable value
      def env(key)
        capture("echo $#{key}").to_s.strip
      end
    end
  end
end