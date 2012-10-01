require 'RubyCrypto'
require 'server/server_socket'

module SquirrelDB

  module Server

    # A server that operates with secure connections.
    class CryptoServer

      # Creates and starts a new server.
      # +port+:: The port this server listens at.
      # +crypto_info+:: A hash table containing a binary string +public_key+ and the
      #                 number of bits used for Diffie Hellman +dh_modulus_size+.
      def self.run(port, crypto_info, &block)
        new(port, crypto_info).run(&block)
      end

      def run(&block)
      TCPServer.open(@port) do |server|
          until @stop
            Thread.start(server.accept) do |socket|
              Logging.mdc['client'] = socket.remote_address.getnameinfo.join(" ")
              begin
                begin
                  client = ServerSocket.open(socket, @signer, @crypto_info)
                rescue IOError, SystemCallError => e
                  @log.info('Unsuccessful connection attempt.')
                  @log.info(e)
                  raise
                rescue Exception => e
                  @log.info('Internal error.')
                  @log.info(e)
                  stop
                  raise
                end # begin
                yield client
              ensure
                client.close unless client.closed?
                socket.close unless socket.closed?
              end # begin
            end # Thread.start
          end # until
        end # TCPServer.open
      end # run

      # Stops the server main loop
      # *WARNING* Does not stop the client threads.
      def stop
        @stop = true
      end

      protected

      # +port+:: The port this server listens at.
      # +crypto_info+:: A hash table containing a binary string +public_key+ and the
      #                 number of bits used for Diffie Hellman +dh_bits+.
      def initialize(port, crypto_info)
        @port = port
        @crypto_info = crypto_info
        @signer = Crypto::ElgamalSigner.new(crypto_info[:private_key])
        @crypto_info = crypto_info
        @log = Logging.logger[self]
      end

    end

  end

end
