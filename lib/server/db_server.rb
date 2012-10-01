require 'server/secure_server'

module SquirrelDB
  
  module Server
    
    class DBServer
      
      # +config+:: A hash table containing at least the keys +:port+, +:public_key+, +:private_key+
      #            and +:dh_bits+
      def initialize(config)
        @log = Logger.logger[self]
      end
      
      # Runs the a server for a database.
      # +database+:: The database to which the commands should be passed.
      def run(database)
        SecureServer.run(port, config) do |client|
          @log.info "Client connected."
          while line = client.gets
            @log.debug { "Got request #{line.dump} from client." }
            if line[0] == ':'
              line.slice!(0)
            else
              if line.chomp == "close"
                break
              else
                @log.error "Unknown server command #{line.dump} received from client and ignored."
              end
            end
            database.execute(database.compile(line))
            @log.debug { "Responded #{response}." }
            client.puts response
          end
          @log.info "Client disconnected."
        end
      end
        
    end
    
  end

end
