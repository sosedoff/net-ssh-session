require 'open3'
require 'net/ssh'
require 'net/ssh/shell'
require 'net/ssh/session_helpers'
require 'net/ssh/session_command'

module Net
  module SSH
    class Session
      include Net::SSH::SessionHelpers

      attr_reader :host, :user, :password
      attr_reader :connection, :shell
      attr_reader :options

      # Initialize a new ssh session
      # @param host [String] remote hostname or ip address
      # @param user [String] remote account username
      # @param password [String] remote account password
      def initialize(host, user, password='')
        @host = host
        @user = user
        @password = password
      end

      # Establish connection with remote server
      # @return [Boolean]
      def open
        @connection = Net::SSH.start(host, user, :password => password)
        @shell = @connection.shell
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
      # @return [SessionCommand]
      def run(command)
        output = ''

        exit_code = exec(command) do |process, data|
          output << data
        end

        SessionCommand.new(command, output, exit_code)
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
    end
  end
end