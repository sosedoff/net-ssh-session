require 'open3'
require 'net/ssh'
require 'net/ssh/shell'
require 'net/ssh/session_helpers'
require 'net/ssh/session_command'

module Net
  module SSH
    class Session
      VERSION = '0.1.0'
      
      include Net::SSH::SessionHelpers

      attr_reader :host, :user, :password
      attr_reader :connection, :shell
      attr_reader :options
      attr_reader :logger
      attr_reader :history
      attr_reader :stream

      # Initialize a new ssh session
      # @param host [String] remote hostname or ip address
      # @param user [String] remote account username
      # @param password [String] remote account password
      def initialize(host, user, password='')
        @host     = host
        @user     = user
        @password = password
        @history  = []
      end

      # Establish connection with remote server
      # @param timeout [Integer] max timeout in seconds
      # @return [Boolean]
      def open(timeout=nil)
        if timeout && timeout > 0
          with_timeout(timeout) { establish_connection }
        else
          establish_connection
        end
      end

      # Close connection with remote server
      # @return [Boolean]
      def close
        shell.close!
      end

      def on_output(&block)
        @on_output = block
      end

      # Execute command
      # @param command [String] command to execute
      # @param on_output [Block] output event block
      # @return [Integer] command execution exit code
      def exec(command, &on_output)
        status = nil
        shell.execute(command) do |process|
          process.on_output(&on_output)
          process.on_error_output(&on_output)
          process.on_finish { |p| status = p.exit_status }
        end
        shell.session.loop(1) { status.nil? }
        status
      end

      # Execute a single command
      # @param command [String] comand to execute
      # @param options [Hash] execution options
      # @return [SessionCommand]
      def run(command, options={})
        output  = ''
        t_start = Time.now

        exit_code = exec(command) do |process, data|
          output << data
          stream.call(output) if stream
          yield data if block_given?
        end

        t_end = Time.now

        cmd = SessionCommand.new(
          command, output, exit_code, 
          t_end - t_start
        )

        history << cmd unless options[:history] == false
        logger.info(cmd.to_s) if logger

        cmd
      end

      # Execute multiple commands
      # @param commands [Array] set of commands to execute
      # @param options [Hash] execution options
      # @return [Array] set of command execution results
      # 
      # Execution options are the following:
      # options[:break] - If set to `true`, execution chain will break on first failed command
      #
      def run_multiple(commands=[], options={})
        results = []

        [commands].flatten.compact.each do |cmd|
          result = run(cmd)
          yield(result) if block_given?
          results << result
          break if results.last.failure? && options[:break] == true
        end

        results
      end

      # Set a global session logger for commands
      def logger=(log)
        @logger = log
      end

      def stream=(proc)
        @stream = proc
      end

      private

      def establish_connection
        @connection = Net::SSH.start(host, user, :password => password)
        @shell = @connection.shell
      end
    end
  end
end