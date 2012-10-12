#encoding: UTF-8

require 'strscan'
require 'forwardable'

module SquirrelDB

  module Client
  
    # Handles a command buffer
    class CommandBuffer
      
      # Flushes the command buffer and executes all commands that are terminated with a ";"
      def flush
        scanner = StringScanner.new(@buffer)
        requests = []
        while command = scanner.scan_until(/;/)
          command.chop!
          requests << {"request_type" => "sql", "sql" => command}
        end
        @buffer = scanner.rest
        requests.each { |r| @client.request(r) }
        @client.wait_responses
      end
      
      extend Forwardable
      
      def_delegators :@buffer, :clear, :<<, :to_s
      
      protected
      
      # +client+:: The client facade.
      def initialize(client)
        @buffer = String.new
        @client = client
      end
            
    end
    
  end
  
end