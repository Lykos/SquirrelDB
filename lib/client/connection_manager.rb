require 'client/server_connection'

module SquirrelDB
  
  module KeyboardHandler

    # Manages the connections of a client
    class ConnectionManager
      
      attr_reader :user, :host, :port
      
      attr_writer :keyboard_handler

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
        if @aliases.has_key?(host)
          alias_info = @aliases[host]
          host = alias_info[:host]
          if user && alias_info.has_key(:user)
            puts "The user is ambiguous because it is defined by the alias and by the user."
            @keyboard_handler.reactivate
            return
          end 
          user = user || alias_info[:user]
          unless user
            puts "The user is not defined."
            @keyboard_handler.reactivate
            return
          end
          port = alias_info[:port] || port
        end
        disconnect if connected?
        @user = user
        @host = host
        @port = port
        puts "Trying to connect to server. This may take a while."
        @connection = EM.connect(host, port, ServerConnection, @keyboard_handler, @response_handler)
        @connected = true
      end
    
      def request(message)
        @connection.send_message(message)
      end
      
      protected
    
      # +response_handler+:: An object that handles responses from the server.
      # +config+:: A hash table containing at least the key +:aliases+
      def initialize(response_handler, config)
        @aliases = config[:aliases]
        @response_handler = response_handler
        @connected = false
      end
      
    end
      
  end

end
