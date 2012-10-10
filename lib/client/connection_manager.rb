require 'client/server_connection'

module SquirrelDB
  
  module KeyboardHandler

    # Manages the connections of a client and creates and manages the underlying sockets.
    class ConnectionManager
      
      attr_reader :user, :host, :port

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
        
      def connected?
        @connected
      end
    
      def disconnect
        raise IOError, "Connection is already closed." if !connected?
        @connection.send_message(JSON::fast_generate({:request_type => :close})) if @connection.connected?
        @connection.close_connection_after_writing
        @connection.close_connection
        @connected = false
      end
          
      # Connects to the given +host+ at port +port+ with user +user+.
      def connect(user, host, port)
        raise IOError, "Connection is already open." if connected?
        if @aliases.has_key?(host)
          alias_info = @aliases[host]
          host = alias_info[:host]
          raise RuntimeError, "The user is defined by the alias and by the user." if user && alias_info.has_key(:user)
          user = user || alias_info[:user]
          user = alias_info[:port] || port
        end
        @user = user
        @host = host
        @port = port
        @connection = EM.connect(host, port, ServerConnection, @response_handler, @validate_key)
        @connected = true
      end
    
      def request(message)
        @connection.send_message(message)
      end
      
      protected
    
      # +config+:: A hash table containing at least the key +:aliases+
      # +response_handler+:: An object that handles responses from the server.
      # +validate_key:: A Proc object that takes a host and a public key as input and returns
      #                         true if this key is accepted and false otherwise.
      def initialize(aliases, response_handler, validate_key)
        @aliases = aliases
        @response_handler = response_handler
        @validate_key = validate_key
        @connected = false
      end
      
    end
      
  end

end
