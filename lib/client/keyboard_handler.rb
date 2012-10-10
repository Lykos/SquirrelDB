require 'client/command_state'
require 'client/prompt_state'
require 'client/key_validate_state'
require 'client/connected_command_state'
require 'RubyCrypto'
gem 'eventmachine'
require 'eventmachine'

module SquirrelDB
  
  module Client
    
    class KeyboardHandler < EventMachine::Connection
      
      include EM::Protocols::LineText2
      
      attr_reader :prompt_state, :command_state, :key_validate_state, :connected_command_state
      
      def receive_line(line)
        pause
        @state.receive_line(line)
      end
      
      def reactivate(*args)
        @state.activate(*args)
        resume
      end
      
      def activate(state, *args)
        @state = state
        @state.activate(*args)
        resume
      end
      
      # +responses+:: The number of responses the keyboard handler should wait for.
      def wait_responses(responses)
        @responses = responses
      end
      
      # Get one response and reactivate, if we have enough
      def respond
        @responses -= 1
        reactivate if @responses == 0
      end
      
      protected
      
      def initialize(command_handler, connection_manager, key_validator)
        @prompt_state = PromptState.new(self)
        @key_validate_state = KeyValidateState.new(self, connection_manager, key_validator)
        @command_state = CommandState.new(self, command_handler, connection_manager)
        @connected_command_state = ConnectedCommandState.new(self, command_handler, connection_manager)
        @state = @command_state
      end
    
    end
    
  end
      
end
