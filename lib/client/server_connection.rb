gem 'eventmachine'
require 'eventmachine'
require 'client/client_protocol'
require 'errors/communication_error'
require 'client/server_hello_state'

module SquirrelDB
  
  module Client
    
    class ServerConnection < EventMachine::Connection
      
      def initialize(client)
        @client = client
        @protocol = ClientProtocol.new
        @state = ServerHelloState.new(self, @protocol)
      end
      
      def connection_completed
        send_data(@protocol.client_hello)
      end
      
      def close_connection(*args)
        @intentionally = true
        super
      end
      
      def unbind
        @connected = false
        @client.connection_lost unless @intentionally
      end
      
      def connection_established
        @connected = true
        @client.connection_established(@protocol.public_key)
      end
      
      def receive_data(data)
        @state = @state.receive_data(data)
      end
      
      def receive_message(message)
        @client.handle_response(message)
      end

      def connected?
        @connected
      end
      
      def send_message(message)
        raise CommunicationError, "Connection has not been established yet." unless connected?
        @state.send_message(message)
      end
    
    end
    
  end
      
end
