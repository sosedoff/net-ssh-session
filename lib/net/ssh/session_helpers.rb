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
      # @return [String]
      def read_file(path)
        run("cat #{path}")
      end

      # Check if remote directory exists
      # @param path [String] directory path
      # @return [Boolean]
      def directory_exists?(path)
        run("test -d #{path}").success?
      end

      # Check if remote file exists
      # @param path [String] file path
      # @return [Boolean]
      def file_exists?(path)
        run("test -f #{path}").success?
      end

      # Check if process with PID is running
      # @param pid [String] process id
      # @return [Boolean]
      def process_exists?(pid)
        run("ps -p #{pid}").success?
      end
    end
  end
end