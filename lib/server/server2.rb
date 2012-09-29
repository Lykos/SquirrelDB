require 'RubyCrypto'
require 'crypto/server_socket'

module Crypto

  class Server

    def self.run(log, port, raw_public_key, raw_private_key, dh_bits, &block)
      new(log, port, raw_public_key, raw_private_key, dh_bits).run(&block)
    end

    def initialize(log, port, raw_public_key, raw_private_key, dh_bits)
      @port = port
      @raw_public_key = raw_public_key
      @elgamal_signer = ElgamalSigner.new(raw_private_key)
      @dh_bits = dh_bits
    end

    def run(&block)
      TCPServer.open(@port) do |server|
        loop do
          Thread.start(server.accept) do |socket|
            begin
              client = ServerSocket.open(socket, @elgamal_signer, @raw_public_key, @dh_bits)
              yield client
            rescue Exception => e
              log.puts "Client caused exception:", e, e.backtrace.join("\n")
            ensure
              client.close unless client.closed?
              socket.close unless socket.closed?
            end
          end
        end
      end
    end

  end

end
