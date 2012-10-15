require 'client/command_state'
require 'client/prompt_state'
require 'client/key_validate_state'
require 'client/connected_command_state'
gem 'eventmachine'
require 'eventmachine'

module SquirrelDB
  
  module Client
    
    class KeyboardHandler < EventMachine::Connection
      
      include EM::Protocols::LineText2
      
      attr_reader :prompt_state, :command_state, :key_validate_state, :connected_command_state
      
      # Forwards the line to its state and deactivates itself
      def receive_line(line)
        begin
          pause
          threads  threads  @state.receive_line(line)
        rescue Exception => e
          puts e
          puts e.backtrace
          @client.close_session
        end
      end
      
      # Activate the previous state with the given arguments.
      # +args+:: The arguments handled to the state during activation.
      def reactivate(*args)
        @state.activate(*args)
        resume
      end
      
      # Activate a given state with the given arguments.
      # +state+:: Either a state object or a symbol that represents a state.
      # +args+:: The arguments handled to the state during activation.
      def activate(state, *args)
        @state = state.is_a?(Symbol) ? send(state) : state
        @state.activate(*args)
        resume
      end
      
      protected
      
      def initialize(client)
        @client = client
        @prompt_state = PromptState.new(self)
        @key_validate_state = KeyValidateState.new(self, client)
        @command_state = CommandState.new(self, client)
        @connected_command_state = ConnectedCommandState.new(self, client)
        @state = @command_state
      end
    
    end
    
  end
      
end
