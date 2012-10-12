require 'client/server_connection'
require 'forwardable'

module SquirrelDB
  
  module Client

    # Manages the connections of a client
    class ConnectionManager
      
      attr_reader :user, :host, :port
      
      extend Forwardable
      
      def_delegators :@connection, :connected?
            
      def user
        raise "Not connected." unless connection_open?
        @user
      end
      
      def host
        raise "Not connected." unless connection_open?
        @host
      end
      
      def port
        raise "Not connected." unless connection_open?
        @port
      end
        
      # Returns true if the client thinks he is connected. Note that this is not the same as +connected?+, which
      # returns true only if the connection is fully established.
      def connection_open?
        @connection_open
      end
      
      # Close the connection after the server disconnected, i.e. finish writing or sending a "close" message makes no sense.
      def disconnect_by_server
        @connection.close_connection
        @connection_open = false
      end
    
      # Disconnect from server and notify the server that we do so.
      def disconnect
        if connected?
          request({:request_type => :close}) 
          @connection.close_connection_after_writing
          timer = EM::PeriodicTimer.new(0.1) do
            unless connected?
              timer.cancel
              @connection_open = false
            end
          end
        elsif connection_open?
          @connection.close_connection
          @connection_open = false
        else
          raise "Not connected."
        end
      end
          
      # Connects to the given +host+ at port +port+ with user +user+.
      def connect(user, host, port)
        raise "Connection already open." if connection_open?
        @user = user
        @host = host
        @port = port
        @connection = EM.connect(host, port, ServerConnection, @client)
        @connection_open = true
      end
      
      # Sets the request id and sends it to the server
      # +message+:: A hash table
      def request(message)
        raise "Cannot send #{message}, not connected to server." unless connected?
        message["id"] = @request_id
        @request_id += 1
        @connection.send_message(JSON::fast_generate(message))
      end
      
      # +client+:: The client facade.
      def initialize(client)
        @client = client
        @request_id = 0
        @connection_open = false
      end
      
    end
      
  end

end
