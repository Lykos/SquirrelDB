require 'json'

module SquirrelDB
  
  module Server
    
    class ClientSession
      
      # +database+:: The database
      # +connection+:: The connection to communicate with the client
      def initialize(database, connection)
        @database = database
        @connection = connection
        @log = Logging.logger[self]
      end
      
      # Receive and handle a message
      def receive_message(message)
        @log.debug { "Got request #{message.dump} from client." }
        begin
          request = JSON::load(message)
        rescue JSON::JSONError => e
          @log.error "Invalid JSON received from client."
          @log.error e
          response = JSON::fast_generate({:response_type => :error, :error => :invalid_json, :reason => e.to_s})
        else
          if request[:request_type] == :close
            @log.debug "Closing after close request."
            @connection.close_connection_after_write
          elsif request[:request_type] == :sql
            begin
              statement = @database.compile(request[:sql])
            rescue UserError => e
              response = JSON::fast_generate({:response_type => :error, :error => e.class.name.intern, :reason => e.to_s})
            end
            if statement.query?
              tuples = @database.query(statement)
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
        @connection.send_message(response)
      end
      
      def close
        @connection.send_message(JSON::fast_generate({:response_type => :close}))
      end
        
    end
    
  end

end
