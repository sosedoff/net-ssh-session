require 'open3'
require 'net/ssh'
require 'net/ssh/shell'
require 'net/ssh/session_helpers'
require 'net/ssh/session_command'

module Net
  module SSH
    class Session
      include Net::SSH::SessionHelpers

      attr_reader :host, :user
      attr_reader :connection, :shell
      attr_reader :options
      attr_reader :logger
      attr_reader :history
      attr_reader :timeout

      # Initialize a new ssh session
      # @param [String] remote hostname or ip address
      # @param [String] remote account username
      # @param [Hash] options hash
      # This method accepts the following options (all are optional):
      #
      # * :auth_methods => an array of authentication methods to try
      # * :compression => the compression algorithm to use, or +true+ to use
      #   whatever is supported.
      # * :compression_level => the compression level to use when sending data
      # * :config => set to +true+ to load the default OpenSSH config files
      #   (~/.ssh/config, /etc/ssh_config), or to +false+ to not load them, or to
      #   a file-name (or array of file-names) to load those specific configuration
      #   files. Defaults to +true+.
      # * :encryption => the encryption cipher (or ciphers) to use
      # * :forward_agent => set to true if you want the SSH agent connection to
      #   be forwarded
      # * :global_known_hosts_file => the location of the global known hosts
      #   file. Set to an array if you want to specify multiple global known
      #   hosts files. Defaults to %w(/etc/ssh/known_hosts /etc/ssh/known_hosts2).
      # * :hmac => the hmac algorithm (or algorithms) to use
      # * :host_key => the host key algorithm (or algorithms) to use
      # * :host_key_alias => the host name to use when looking up or adding a
      #   host to a known_hosts dictionary file
      # * :host_name => the real host name or IP to log into. This is used
      #   instead of the +host+ parameter, and is primarily only useful when
      #   specified in an SSH configuration file. It lets you specify an 
      #   "alias", similarly to adding an entry in /etc/hosts but without needing
      #   to modify /etc/hosts.
      # * :kex => the key exchange algorithm (or algorithms) to use
      # * :keys => an array of file names of private keys to use for publickey
      #   and hostbased authentication
      # * :logger => the logger instance to use when logging
      # * :paranoid => either true, false, or :very, specifying how strict
      #   host-key verification should be
      # * :password => the password to use to login
      # * :port => the port to use when connecting to the remote host
      # * :properties => a hash of key/value pairs to add to the new connection's
      #   properties (see Net::SSH::Connection::Session#properties)
      # * :proxy => a proxy instance (see Proxy) to use when connecting
      # * :rekey_blocks_limit => the max number of blocks to process before rekeying
      # * :rekey_limit => the max number of bytes to process before rekeying
      # * :rekey_packet_limit => the max number of packets to process before rekeying
      # * :timeout => how long to wait for the initial connection to be made
      # * :user => the user name to log in as; this overrides the +user+
      #   parameter, and is primarily only useful when provided via an SSH
      #   configuration file.
      # * :user_known_hosts_file => the location of the user known hosts file.
      #   Set to an array to specify multiple user known hosts files.
      #   Defaults to %w(~/.ssh/known_hosts ~/.ssh/known_hosts2).
      # * :verbose => how verbose to be (Logger verbosity constants, Logger::DEBUG
      #   is very verbose, Logger::FATAL is all but silent). Logger::FATAL is the
      #   default.
      def initialize(host, user, options={})
        @host          = host
        @user          = user
        @history       = []
        @track_history = true
        @timeout       = options[:timeout]
        @options = options
        
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
        @connection = Net::SSH.start(host, user, options)
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