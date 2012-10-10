gem 'eventmachine'
require 'eventmachine'
require 'client/client_protocol'
require 'errors/internal_connection_error'
require 'client/server_hello_state'

module SquirrelDB
  
  module Client
    
    class ServerConnection < EventMachine::Connection
      
      def initialize(response_handler, validate_key)
        @validate_key = validate_key
        @protocol = ClientProtocol.new
        @state = ServerHelloState.new(self, @protocol)
      end
      
      def post_init
        send_data(@protocol.client_hello)
      end
      
      def receive_data(data)
        @state = state.receive_data(data)
      end
      
      def receive_message(message)
        @response_handler.handle_response(response)
      end

      def connected?
        @state.connected?
      end
      
      def send_message(message)
        raise InternalConnectionError, "Connection has not been established yet." unless connected?
        @state.send_message(message)
      end
    
    end
    
  end
      
end
