#encoding: UTF-8

require 'errors/connection_error'
require 'client/response_handler'
require 'client/keyboard_handler'
require 'client/command_handler'
require 'client/key_validator'
require 'client/server_connection'
require 'errors/internal_connection_error'
require 'RubyCrypto'
require 'errors/encoding_error'
require 'forwardable'
require 'json'

module SquirrelDB

  module Client
  
    # Facade and mediator class for the client
    # TODO This class has become too powerful. Divide the work, if possible and make only a mediator out of it.
    class Client
      
      # Starts the client, activate keyboard and connect to server, if a connection is known.
      def start
        @keyboard_handler = EM.open_keyboard(KeyboardHandler, self)
        if @config[:host]
          connect(@config[:user], @config[:host], @config[:port])
        else
          activate(:command_state)
        end
      end
      
      attr_reader :key_validator, :command_buffer, :config, :user, :host, :port, :keyboard_handler, :command_handler
            
      extend Forwardable
      
      def_delegators :@keyboard_handler, :activate, :reactivate
      
      def_delegators :@response_handler, :handle_response

      def user
        raise "Not connected." unless @connected
        @user
      end
      
      def host
        raise "Not connected." unless @connected
        @host
      end
      
      def port
        raise "Not connected." unless @connected
        @port
      end
        
      # Returns true if the client thinks he is connected. Note that this is not the same as @connection.connected?, which
      # returns true only if the connection is fully established.
      def connected?
        @connected
      end
      
      # Activates the connected state
      # +public_key+:: The public key of the peer.
      def connection_established(public_key)
        activate(:key_validate_state, @host, public_key)
      end
      
      # Close the connection after the server disconnected, i.e. finish writing or sending a "close" message makes no sense.
      def disconnect_by_server
        @connected = false
        @connection.close_connection
        clear_command_buffer
        puts "Connection closed by server."
        activate(:command_state)
      end
    
      # Disconnect from server and notify the server that we do so.
      def disconnect
        raise IOError, "Connection is already closed." if !connected?
        if @connection.connected?
          request({:request_type => :close}) 
          @connection.close_connection_after_writing
          clear_command_buffer
          timer = EM::PeriodicTimer.new(0.1) do
            unless @connection.connected?
              timer.cancel
              @connected = false
              puts "Disconnected from server."
              activate(:command_state)
            end
          end
        else
          @connection.close_connection
          @connected = false
          puts "Disconnected from server."
          activate(:command_state)
        end
      end
          
      # Connects to the given +host+ at port +port+ with user +user+.
      def connect(user, host, port)
        if @aliases.has_key?(host)
          alias_info = @aliases[host]
          host = alias_info[:host]
          if user && alias_info.has_key(:user)
            puts "The user is ambiguous because it is defined by the alias and by the argument."
            @keyboard_handler.reactivate
            return
          end 
          user = user || alias_info[:user]
          port = alias_info[:port] || port
        end
        unless user
          puts "The user is not defined."
          @keyboard_handler.reactivate
          return
        end
        unless port
          puts "The port is not defined."
          @keyboard_handler.reactivate
          return
        end
        disconnect if connected?
        timer = EM::PeriodicTimer.new(0.1) do
          unless connected?
            timer.cancel
            @user = user
            @host = host
            @port = port
            puts "Trying to connect to server. This may take a while."
            @connection = EM.connect(host, port, ServerConnection, self)
            @connected = true
          end
        end
      end
      
      # Flushes the command buffer and executes all commands that are terminated with a ";"
      def flush_command_buffer
        scanner = StringScanner.new(@command_buffer)
        requests = []
        while command = scanner.scan_until(/;/)
          command.chop!
          requests << {"request_type" => "sql", "sql" => command}
        end
        @command_buffer = scanner.rest
        wait_responses(requests.length)
        requests.each { |r| request(r) }
      end
      
      # Clears the command buffer without executing anything
      def clear_command_buffer
        @command_buffer.clear
      end
      
      # Sets the request id and sends it to the server
      # +message+:: A hash table
      def request(message)
        raise "Cannot send #{message}, not connected to server." unless connected?
        message["id"] = @request_id
        @request_id += 1
        @connection.send_message(JSON::fast_generate(message))
      end
      
      # +responses+:: The number of responses the keyboard handler should wait for before it automatically reactivates the last state.
      def wait_responses(responses, *args)
        if responses > 0
          @args = args
          @responses = responses
        else
          reactivate(*args)
        end
      end
      
      # Get one response and reactivate, if we have enough
      def count_response
        @responses -= 1
        reactivate(*@args) if @responses <= 0
      end

      # Appends +string+ to the command buffer.
      def append_command_buffer(string)
        @command_buffer << string
      end
      
      # Reactivates the keyboard for an unconnected state.
      def connection_lost
        @connected = false
        puts "Connection to server lost."
        @keyboard_handler.activate(@keyboard_handler.command_state)
      end
      
      # Disconnects from server and shuts down the event loop.
      def close_session
        if connected?
          disconnect
          timer = EM::PeriodicTimer.new(0.1) do
            unless connected?
              __close_session
              timer.cancel
            end
          end
        else
          __close_session
        end
      end
      
      protected
      
      # +config+:: Hash table with at least the keys +:port+ and +:aliases+.
      def initialize(config)
        @config = config
        @aliases = config[:aliases]
        @key_validator = KeyValidator.new(@config)
        @response_handler = ResponseHandler.new(self)
        @command_handler = CommandHandler.new(self)
        @command_buffer = String.new
        @request_id = 0
      end
      
      private
      
      def __close_session
        puts "Closing session."
        EM.stop_event_loop
      end
            
    end
    
  end
  
end