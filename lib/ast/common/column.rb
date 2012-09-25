require 'ast/common/element'

module SquirrelDB

  module AST

    class Column < Element

      def initialize(name, type, default, index)
        @name = name
        @type = type
        @default = default
        @index = index
      end

      attr_reader :name, :type, :default, :index
      
      def evaluate(state)
        state.tuple[@index]
      end
      
    end

  end

end
