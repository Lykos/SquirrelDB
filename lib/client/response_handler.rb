require 'client/command_handler'
require 'json'
require 'client/connection_manager'
require 'RubyCrypto'

module SquirrelDB
  
  module Client
    
    class ResponseHandler
      
      attr_writer keyboard_handler, connection_manager

      def handle_response(response)
        begin
          JSON::load(response)
        rescue JSONError => e
          puts "Got invalid JSON from server: #{e}"
        end
        case response[:response_type]
        when :tuples
          puts @tuple_pretty_printer.pretty_print(response[:tuples])
          @keyboard_handler.respond
        when :command_status
          puts response[:message]
          @keyboard_handler.respond
        when :error
          puts "Error: #{response[:reason]}"
          @keyboard_handler.respond
        when :close
          puts "#{response[:reason]}"
          puts "Connection closed by server."
          @connection_manager.disconnect
        else
          puts "Unknown response type #{response[:response_type]}."
        end
      end
      
      protected
      
      def initialize
        @tuple_pretty_printer = TuplePrettyPrinter.new
      end
          
    end
    
  end
      
end
