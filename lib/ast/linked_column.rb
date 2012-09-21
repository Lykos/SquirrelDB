require 'sql/elements/syntatctic_unit'

module SquirrelDB

  module AST

    class LinkedColumn < SyntacticUnit

      def initialize( type, name, index )
        @type = type
        @name = name
        @index = index
      end

      attr_reader :type, :name, :index
      
      def evaluate(state)
        state.tuple[@index]
      end
      
    end

  end

end
