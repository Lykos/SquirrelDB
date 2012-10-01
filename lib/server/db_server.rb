require 'server/crypto_server'
require 'server/client_session'
require 'thread'

module SquirrelDB
  
  module Server
    
    class DBServer
      
      # +config+:: A hash table containing at least the keys +:port+, +:public_key+, +:private_key+
      #            and +:dh_modulus_size+
      def initialize(config)
        @config = config
        @log = Logging.logger[self]
        @session_lock = Mutex.new
        @sessions = []
        @stop_lock = Mutex.new
      end
      
      # Runs the a server for a database.
      # +database+:: The database to which the commands should be passed.
      def run(database)
        @log.info "Started server."
        begin
          @crypto_server = CryptoServer.new(@config[:port], @config)
          @crypto_server.run do |client|
            begin
              session = ClientSession.new(database, client, @config)
              if @stop
                session.refuse
              else
                @session_lock.synchronize { @sessions << session }
                session.run
                @session_lock.synchronize { @sessions.delete(session) }
              end
            rescue Exception => e
              @log.error "Internal error."
              @log.error e
              stop
            end
          end
        rescue Exception => e
          @log.error "Internal error."
          @log.error e
          stop
        end
        @log.info "Server shut down."
      end
      
      def stop(reason=nil)
        @stop_lock.synchronize do
          if !@stop
            @log.info "Shutting server down."
            @stop = true
            @session_lock.synchronize { @sessions.each { |s| s.stop(reason) } }
            # TODO Wait until they are really stopped.
            @crypto_server.stop
          end
        end
      end
        
    end
    
  end

end
