require 'client/tuple_pretty_printer'

module SquirrelDB
  
  module Client
    
    class ResponseHandler
      
      def handle_response(response)
        begin
          response = JSON::load(response)
        rescue JSONError => e
          puts "Got invalid JSON from server: #{e}"
          @client.count_response
          return
        end
        case response["response_type"]
        when "tuples"
          puts @tuple_pretty_printer.pretty_print(response["tuples"])
        when "command_status"
          puts response["message"]
        when "error"
          puts response["error"] + (response["reason"] ? ": #{response["reason"]}" : "")
        when "close"
          puts "#{response["reason"]}" if response["reason"]
          @client.disconnect_by_server
        else
          puts "Unknown response type #{response["response_type"]}."
        end
        @client.count_response
      end
      
      protected
      
      def initialize(client)
        @tuple_pretty_printer = TuplePrettyPrinter.new
        @client = client
      end
          
    end
    
  end
      
end
