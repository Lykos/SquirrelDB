require 'RubyCrypto'
require 'crypto/server_socket'

module RubyDB

  class Server

    def self.run(logger, port, crypto_info, &block)
      new(log, port, crypto_info).run(&block)
    end

    def initialize(logger, port, crypto_info)
      @port = port
      @signer = Crypto::ElgamalSigner(crypto_info.raw_private_key)
      @crypto_info = crypto_info
    end

    def run(&block)
      TCPServer.open(@port) do |server|
        loop do
          Thread.start(server.accept) do |socket|
            begin
              client = ServerSocket.open(socket, @crypto_info)
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
