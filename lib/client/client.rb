#encoding: UTF-8

require 'errors/connection_error'
require 'client/connection_manager'
require 'client/response_handler'
require 'client/keyboard_handler'
require 'client/command_handler'
require 'client/key_validator'
require 'errors/internal_connection_error'
require 'RubyCrypto'
require 'errors/encoding_error'

module SquirrelDB

  module Client
  
    # Facade class for the client
    class Client
      
      def initialize(config)
        @config = config
        @response_handler = ResponseHandler.new
        @key_validator = KeyValidator.new(@config)
        @connection_manager = ConnectionManager.new(@response_handler, @config)
        @response_handler.connection_manager = @connection_manager
        @command_handler = CommandHandler.new(@connection_manager, @config)
        @key_validator = KeyValidator.new(@config)
      end
      
      def start
        @keyboard_handler = EM.open_keyboard(KeyboardHandler, @command_handler, @key_validator, @connection_manager) do |kh|
          @connection_manager.keyboard_handler = kh
          @command_handler.keyboard_handler = kh
          @response_handler.keyboard_handler = kh
        end
        if @config[:host]
          @connection_manager.connect(@config[:user], @config[:host], @config[:port])
        else
          @keyboard_handler.activate(@keyboard_handler.command_state)
        end
      end
      
    end
    
  end
  
end