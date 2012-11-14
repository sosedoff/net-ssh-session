module Net
  module SSH
    class SessionCommand
      attr_reader   :command, :output, :exit_code
      attr_reader   :duration
      attr_accessor :start_time, :finish_time
      
      # Initialize a new session command
      # @param command [String] original command
      # @param output [String] command execution output
      # @param exit_code [Integer] command execution exit code
      # @param duration [Float] execution time in seconds
      def initialize(command, output, exit_code, duration=0)
        @command   = command
        @output    = output || ''
        @exit_code = Integer(exit_code) rescue 1
        @duration  = Float(duration)
      end

      # Check if exit code is successful
      # @return [Boolean]
      def success?
        exit_code == 0
      end

      # Check if exit code is not successful
      # @return [Boolean]
      def failure?
        exit_code != 0
      end

      # Get command string representation
      # @return [String]
      def to_s
        "[#{command}] => #{exit_code}, #{output.to_s.bytesize} bytes, #{duration} seconds"
      end
    end
  end
end