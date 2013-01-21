module Net
  module SSH
    class SessionCommand
      attr_reader :command, :duration
      attr_accessor :output, :exit_code
      attr_accessor :start_time, :finish_time
      
      # Initialize a new session command
      #
      # @param [String] original command
      # @param [String] command execution output
      # @param [Integer] command execution exit code
      # @param [Float] execution time in seconds
      def initialize(command, output=nil, exit_code=nil, duration=0)
        @command   = command
        @output    = output || ''
        @exit_code = Integer(exit_code) rescue 1 if exit_code != nil
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

      alias :error? :failure?

      # Get command string representation
      # @return [String]
      def to_s
        "[#{command}] => #{exit_code}, #{output.to_s.bytesize} bytes, #{duration} seconds"
      end

      # Get command hash representation
      # @return [Hash]
      def to_hash
        {
          'command'     => command,
          'output'      => output,
          'exit_code'   => exit_code,
          'start_time'  => start_time,
          'finish_time' => finish_time,
          'duration'    => duration
        }
      end
    end
  end
end