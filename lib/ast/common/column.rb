require 'ast/common/element'

module SquirrelDB

  module AST

    class Column < Element

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
