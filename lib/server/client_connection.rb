gem 'eventmachine'
require 'eventmachine'
require 'errors/internal_error'
require 'errors/communication_error'
require 'errors/user_error'
require 'server/client_session'
require 'server/client_hello_state'
require 'server/server_protocol'
require 'socket'

module SquirrelDB
  
  module Server
    
    # Represents the connection to a client and handles establishing a secure connection,
    # creation of the session 
    class ClientConnection < EventMachine::Connection
      
      # +server+:: The database server
      # +database+:: The database
      # +signer+:: An object capable of signing messages
      # +config+:: A hash table containing at least the keys +:port+, +:public_key+, +:private_key+
      #            and +:dh_modulus_size+
      def initialize(server, database, signer, config)
        @server = server
        @session = ClientSession.new(database, self)
        @state = ClientHelloState.new(self, ServerProtocol.new(signer, config))
        @log = Logging.logger[self]
      end
      
      def post_init
        @client_name = Addrinfo.new(get_peername).getnameinfo.join(":")
        Logging.mdc['client'] = @client_name
        @log.debug("A client has connected.")
      end
    
      def close_connection(*args)
        @intentionally = true
        super
      end
      
      def unbind
        Logging.mdc['client'] = @client_name
        @log.debug("Connection to client lost.") unless @intentionally
      end
            
      # Receive raw data through the connection
      def receive_data(data)
        Logging.mdc['client'] = @client_name
        begin
          @state = @state.receive_data(data)
        rescue UserError => e
          @log.error(e)
          close_connection_after_writing
        rescue InternalError => e
          @log.fatal(e)
          @server.stop
        rescue Exception => e
          @log.fatal(e)
          @server.stop
        end
      end
      
      def connected?
        @state.connected?
      end
      
      # Send a message through the secure connection.
      def send_message(message)
        raise CommunicationError, "Not connected yet." unless connected?
        @state.send_message(message)
      end
      
      # Receive a message from the secure connection.
      def receive_message(message)
        @session.receive_message(message)
      end
        
    end
    
  end

end
