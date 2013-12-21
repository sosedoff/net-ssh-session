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
      attr_reader :logger
      attr_reader :history
      attr_reader :timeout

      # Initialize a new ssh session
      # @param [String] remote hostname or ip address
      # @param [String] remote account username
      # @param [String] remote account password
      # @param [Hash] options hash
      def initialize(host, user, password='', options={})
        @host          = host
        @user          = user
        @port          = options[:port] || 22
        @password      = password
        @history       = []
        @track_history = true
        @timeout       = options[:timeout]

        if options[:history] == false
          @track_history = false
        end

        if @timeout && !@timeout.kind_of?(Integer)
          raise ArgumentError, "Timeout value should be numeric"
        end
      end

      # Establish connection with remote server
      # @param [Integer] max timeout in seconds
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
      # @param [String] command to execute
      # @param [Block] output event block
      # @return [Integer] command execution exit code
      def exec(command, &on_output)
        status = nil

        handle_timeout do
          shell.execute(command) do |process|
            process.on_output(&on_output)
            process.on_error_output(&on_output)
            process.on_finish { |p| status = p.exit_status }
          end

          shell.session.loop(1) { status.nil? }
        end

        status
      end

      # Execute a single command
      # @param [String] comand to execute
      # @param [Hash] execution options
      # @return [SessionCommand]
      def run(command, options={})
        output  = ''
        t_start = Time.now

        exit_code = exec(command) do |process, data|
          output << data
          yield data if block_given?
        end

        t_end = Time.now

        cmd = SessionCommand.new(
          command, output, exit_code, 
          t_end - t_start
        )

        cmd.start_time = t_start
        cmd.finish_time = t_end

        if options[:history] == true || @track_history == true
          history << cmd
        end

        logger.info(cmd.to_s) if logger

        cmd
      end

      # Execute multiple commands
      # @param [Array] set of commands to execute
      # @param [Hash] execution options
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
      # @param [Logger] logger instance
      def logger=(log)
        @logger = log
      end

      # Get last executed command
      # @return [SessionCommand]
      def last_command
        history.last
      end

      # Execute a dynamic command
      # @param [String] command name
      # @params [Array] command arguments
      def method_missing(name, *args)
        run("#{name} #{args.join(' ')}".strip)
      end

      private

      def establish_connection
        opts = {
          :password => @password,
          :port     => @port
        }

        @connection = Net::SSH.start(host, user, opts)
        @shell = @connection.shell
      end

      def handle_timeout(&block)
        if timeout
          Timeout.timeout(timeout) { block.call(self) }
        else
          block.call(self)
        end
      end
    end
  end
end