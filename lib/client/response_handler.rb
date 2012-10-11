require 'client/command_handler'
require 'client/tuple_pretty_printer'
require 'json'
require 'client/connection_manager'
require 'RubyCrypto'

module SquirrelDB
  
  module Client
    
    class ResponseHandler
      
      attr_writer :keyboard_handler, :connection_manager

      def handle_response(response)
        begin
          response = JSON::load(response)
        rescue JSONError => e
          puts "Got invalid JSON from server: #{e}"
          @keyboard_handler.respond
          return
        end
        case response["response_type"]
        when "tuples"
          puts @tuple_pretty_printer.pretty_print(response["tuples"])
        when "command_status"
          puts response["message"]
        when "error"
          puts "Error: #{response["reason"]}"
        when "close"
          puts "#{response["reason"]}"
          puts "Connection closed by server."
          @connection_manager.disconnect_from_server
        else
          puts "Unknown response type #{response["response_type"]}."
        end
        @keyboard_handler.respond
      end
      
      protected
      
      def initialize
        @tuple_pretty_printer = TuplePrettyPrinter.new
      end
          
    end
    
  end
      
end
