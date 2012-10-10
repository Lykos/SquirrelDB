require 'client/command_handler'
require 'client/response_handler'
require 'json'
require 'client/connection_manager'
require 'RubyCrypto'
gem 'eventmachine'
require 'eventmachine'

module SquirrelDB
  
  module Client
    
    # Represents a state of the keyboard handler in which he has to ask for a prompt and then act accordingly.
    class PromptState
      
      def activate(prompt, callback)
        @callback = callback
        print prompt
        @keyboard_handler.resume
      end

      def receive_line(line)
        @callback.call(line)
      end
      
      def initialize(keyboard_handler)
        @keyboard_handler = keyboard_handler
      end
    
    end
    
  end
      
end
