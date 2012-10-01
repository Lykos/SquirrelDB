require 'RubyCrypto'
require 'server/server_socket'

module RubyDB

  module Server

    # A server that operates with secure connections.
    class CryptoServer

      # Creates and starts a new server.
      # +logger+:: A logger for errors.
      # +port+:: The port this server listens at. 
      # +crypto_info+:: A hash table containing a binary string +public_key+ and the
      #                 number of bits used for Diffie Hellman +dh_bits+.
      def self.run(port, crypto_info, &block)
        new(port, crypto_info).run(&block)
      end
  
      def run(&block)
        TCPServer.open(@port) do |server|
          loop do
            Thread.start(server.accept) do |socket|
              Logger.mdc['client'] = client.remote_addess.get_name.info.join(" ")
              begin
                client = ServerSocket.open(socket, @crypto_info)
                yield client
              ensure
                client.close unless client.closed?
                socket.close unless socket.closed?
              end # begin
            end # Thread.start
          end # loop
        end # TCPServer.open
      end # run
      
      def stop
        # TODO
      end
  
      protected
      
      # +port+:: The port this server listens at. 
      # +crypto_info+:: A hash table containing a binary string +public_key+ and the
      #                 number of bits used for Diffie Hellman +dh_bits+.
      def initialize(port, crypto_info)
        @port = port
        @crypto_info = crypto_info
        @signer = Crypto::ElgamalSigner(crypto_info.raw_private_key)
        @crypto_info = crypto_info
      end
    
    end

  end

end
