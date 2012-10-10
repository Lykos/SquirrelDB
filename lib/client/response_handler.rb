require 'client/command_handler'
require 'json'
require 'client/connection_manager'
require 'RubyCrypto'

module SquirrelDB
  
  module Client
    
    class ResponseHandler

      def handle_response(response)
        begin
          JSON::load(response)
        rescue JSONError => e
          puts "Got invalid JSON from server: #{e}"
        end
        case response[:response_type]
        when :tuples
          puts response[:tuples].map { |t| t.join "\t\t" }
        when :command_status
          puts response[:message] unless response[:message].empty?
        when :error
          puts "Error: #{response[:reason]}"
        when :close
          puts "#{response[:reason]}"
          puts "connection closed."
          @client.disconnect
        else
          puts "Unknown response type #{response[:response_type]}."
        end # case
      end
      
      protected
      
      def initialize(client)
        @client = client
      end
    
    end
    
  end
      
end
