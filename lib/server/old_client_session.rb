require 'server/crypto_server'
require 'json'
require 'thread'

module SquirrelDB
  
  module Server
    
    class ClientSession
      
      # +database+:: The database
      # +client+:: The socket to communicate with the client.
      # +config+:: A hash table containing at least the keys +:port+, +:public_key+, +:private_key+
      #            and +:dh_modulus_size+
      def initialize(database, client, config)
        @database = database
        @config = config
        @client = client
        @log = Logging.logger[self]
        @stop_mutex = Mutex.new
      end
      
      def refuse
      end
      
      def stop(reason=nil)
        @stop = true
        @reason = reason
      end
      
      # Runs the a server for a database.
      # +database+:: The database to which the commands should be passed.
      def run
        @log.info "Client connected."
        begin
          line = @client.gets
        rescue IOError, SystemCallError => e
          @log.error "Reading from client not possible."
          @log.error e
          raise
        end
        while line = read_client
          __stop if @stopped
          @log.debug { "Got request #{line.dump} from client." }
          begin
            request = JSON::load(line)
          rescue JSON::JSONError => e
            @log.error "Invalid JSON received from client."
            @log.error e
            response = JSON::fast_generate({:response_type => :error, :error => :invalid_json, :reason => e.to_s})
          else
            if request[:request_type] == :close
              @log.debug "Closing after close request."
              break
            elsif request[:request_type] == :sql
              statement = database.compile(request[:sql])
              if statement.query?
                tuples = database.query(statement)
                values = tuples.map { |t| t.values }
                response = JSON::fast_generate({:response_type => :tuples, :tuples => values})
              else
                database.execute(statement)
                response = JSON::fast_generate({:response_type => :command_status, :status => :success, :message => "Success!"})
              end
            else
              @log.error "Unknown request type #{request[:request_type]}"
            end
          end
          write_client(response)
          line = read_client
        end
        @log.info "Client disconnected."
      end
      
      def stopped?
        @stopped
      end
      
      private
      
      def write_client
        @log.debug { "Responding #{response}." }
        begin
          @client.puts response
        rescue IOError, SystemCallError => e
          @log.error "Responding to client not possible."
          @log.error e
          raise
        end
      end
      
      def read_client
        begin
          line = @client.gets
        rescue IOError, SystemCallError => e
          @log.error "Reading from client not possible."
          @log.error e
          raise
        end
        @log.debug { "Got request #{line.dump} from client." }
        line
      end
      
      def __stop
        @stop_mutex.synchronize do
          unless @stopped
            @log.info "Forced stop."
            @client.puts JSON::fast_generate({:response_type => :error, :error => :close, :reason => @reason})
            @stopped = true
          end
        end
      end
        
    end
    
  end

end
