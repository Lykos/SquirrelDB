gem 'eventmachine'
require 'eventmachine'
require 'client/client_protocol'
require 'errors/internal_connection_error'
require 'client/server_hello_state'

module SquirrelDB
  
  module Client
    
    class ServerConnection < EventMachine::Connection
      
      def initialize(connection_manager, keyboard_handler, response_handler)
        @connection_manager = connection_manager
        @keyboard_handler = keyboard_handler
        @protocol = ClientProtocol.new
        @state = ServerHelloState.new(self, @protocol)
      end
      
      def connection_completed
        send_data(@protocol.client_hello)
      end
      
      def close_connection_after_writing(*args)
        @intentionally = true
        super
      end
      
      def close_connection(*args)
        @intentionally = true
        super
      end
      
      def unbind
        @connected = false
        @connection_manager.connection_lost unless @intentionally
      end
      
      def connection_established
        @connected = true
        @keyboard_handler.activate(@keyboard_handler.key_validate_state, @connection_manager.host, @protocol.public_key)
      end
      
      def receive_data(data)
        @state = @state.receive_data(data)
      end
      
      def receive_message(message)
        @response_handler.handle_response(response)
      end

      def connected?
        @connected
      end
      
      def send_message(message)
        raise InternalConnectionError, "Connection has not been established yet." unless connected?
        puts "Sending #{message.dump}."
        @state.send_message(message)
      end
    
    end
    
  end
      
end
