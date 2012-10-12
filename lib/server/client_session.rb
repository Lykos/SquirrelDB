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
        begin
          request = JSON::load(message)
        rescue JSON::JSONError => e
          @log.error "Invalid JSON received from client."
          @log.error e
          response = {"response_type" => "error", "error" => JSONError.name, "reason" => e.to_s}
        else
          @log.debug { "Got request #{request} from client." }
          case request["request_type"]
          when "close"
            @log.debug "Closing after close request."
            @connection.close_connection_after_writing
          when "sql"
            begin
              statement = @database.compile(request["sql"])
              if statement.query?
                tuples = @database.query(statement)
                values = tuples.map { |t| t.values }
                response = {"response_type" => "tuples", "tuples" => values}
              else
                @database.execute(statement)
                response = {"response_type" => "command_status", "status" => "success", "message" => "Success!"}
              end
            rescue UserError => e
              response = {"response_type" => "error", "error" => e.class.name, "reason" => e.to_s}
            end
          else
            @log.error "Unknown request type #{request["request_type"]} received from client."
          end
        end
        if response
          response["id"] = request["id"]
          response["context_info"] = request["context_info"] if request["context_info"]
          @log.debug { "Sending response #{response} to client." }
          @connection.send_message(JSON::fast_generate(response))
        end
      end
      
      def close
        @connection.send_message(JSON::fast_generate({:response_type => :close}))
      end
        
    end
    
  end

end
