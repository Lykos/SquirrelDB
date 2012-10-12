#encoding: UTF-8

require 'errors/connection_error'
require 'client/response_handler'
require 'client/keyboard_handler'
require 'client/command_handler'
require 'client/key_validator'
require 'client/command_buffer'
require 'client/connection_manager'
require 'forwardable'
require 'json'

module SquirrelDB

  module Client
  
    # Facade and mediator class for the client
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
      
      attr_reader :key_validator, :command_buffer, :config, :connection_manager, :keyboard_handler, :command_handler
            
      extend Forwardable
      
      def_delegators :@keyboard_handler, :activate, :reactivate
      
      def_delegators :@response_handler, :handle_response

      def_delegators :@connection_manager, :user, :host, :port, :connected?, :connection_open?
        
      # Returns true if the client thinks he is connected. Note that this is not the same as @connection.connected?, which
      # returns true only if the connection is fully established.
      def connected?
        @connected
      end
          
      # Connects to the given +host+ at port +port+ with user +user+,
      # clears the connection and activates the connected state.
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
        @connection_manager.disconnect if connection_open?
        clear_command_buffer
        timer = EM::PeriodicTimer.new(0.1) do
          unless connection_open?
            timer.cancel
            puts "Trying to connect to server. This may take a while."
            @connection_manager.connect(user, host, port)
          end
        end
      end
      
      # Clears the command buffer and closes the connection
      def disconnected_by_server
        @connection_manager.disconnected_by_server
        clear_command_buffer
        puts "Connection closed by server."
        activate(:command_state)
      end
      
      # Clears the command buffer and closes the connection
      def disconnect
        @connection_manager.disconnect
        clear_command_buffer
        timer = EM.add_periodic_timer(0.1) do
          unless @client.connected?
            timer.cancel
            puts "Disconnected from server."
            @client.activate(:command_state)
          end
        end
      end
      
      # Activates the connected state
      # +public_key+:: The public key of the peer.
      def connection_established(public_key)
        activate(:key_validate_state, host, public_key)
      end
      
      # Flushes the command buffer and executes all commands that are terminated with a ";"
      def flush_command_buffer
        @command_buffer.flush
      end
      
      # Clears the command buffer without executing anything
      def clear_command_buffer
        @command_buffer.clear
      end
      
      # Wait for responses and then reactivate
      def wait_responses(*args)
        if @responses > 0
          @args = args
        else
          reactivate(*args)
        end
      end
      
      def request(req)
        @responses += 1
        @connection_manager.request(req)
      end
      
      # Get one response and reactivate, if we have enough
      def count_response
        @responses -= 1
        reactivate(*@args) if @responses == 0
      end

      # Appends +string+ to the command buffer.
      def append_command_buffer(string)
        @command_buffer << string
      end
      
      # Reactivates the keyboard for an unconnected state.
      def connection_lost
        @connected = false
        puts "Connection to server lost."
        activate(:command_state)
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
        @command_buffer = CommandBuffer.new(self)
        @connection_manager = ConnectionManager.new(self)
        @responses = 0
      end
      
      private
      
      def __close_session
        puts "Closing session."
        EM.stop_event_loop
      end
            
    end
    
  end
  
end