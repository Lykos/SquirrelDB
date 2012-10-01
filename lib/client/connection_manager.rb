require 'socket'
require 'client/client_socket'

module SquirrelDB
  
  module Client

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
        @connected = false
        ObjectSpace.undefine_finalizer(self)
        ConnectionManager.__disconnect(@client_socket, @socket)
      end
          
      def connect(user, host, port)
        raise IOError, "Connection is already open." if connected?
        if @aliases.has_key?(host)
          alias_info = @aliases[host]
          host = alias_info[:host]
          user = user || alias_info[:user]
          user = alias_info[:port] || port
        end
        @socket = TCPSocket.new(host, port)
        @client_socket = ClientSocket.new(@socket, lambda { |key| @validate_key.call(host, key) })
        ObjectSpace.define_finalizer(self, proc { ConnectionManager.__disconnect(@client_socket, @socket) })
        @user = user
        @host = host
        @port = port
        @connected = true
      end
    
      def request(message)
        raise IOError, "Not connected." if !connected?
        @client_socket.puts(message)
        @client_socket.gets
      end
      
      protected
    
      # +config+:: A hash table containing at least the key +:aliases+
      # +public_key_callback+:: A Proc object that takes a host and a public key as input and returns
      #                         true if this key is accepted and false otherwise.
      def initialize(aliases, validate_key)
        @aliases = aliases
        @validate_key = validate_key
        @connected = false
      end
   
      protected
           
      # This has to be a class method such that it can be used in a finalizer
      def self.__disconnect(client_socket, socket)
        begin
          begin
            begin
              client_socket.puts("close") if client_socket && client_socket.writable?
            ensure
              client_socket.close if client_socket && !client_socket.closed?
            end
          ensure
            socket.close if socket && !socket.closed?
          end
        rescue IOError, SystemCallError => e
          warn "Ignored error while disconnecting: #{e}."
          warn e.backtrace.join("\n")
        end
      end
      
    end
      
  end

end
