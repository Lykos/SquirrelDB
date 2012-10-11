require 'ast/common/element'

module SquirrelDB

  module AST

    class BinaryOperation < Element
    
      def initialize( operator, left, right )
        @operator = operator
        @left = left
        @right = right
      end

      attr_reader :operator, :left, :right

      def ==(other)
        super && @operator == other.operator && @left == other.left && @right == other.right
      end
      
      def hash
        @hash ||= [@operator, @left, @right].hash
      end
      
      def type
        if @left.type == @right.type
          @left.type
        else
          raise
        end
      end

      def to_s
        "(" + @left.to_s + " " + @operator.to_s + " " + @right.to_s + ")"
      end

      def inspect
        "(" + @left.inspect + " " + @operator.to_s + " " + @right.inspect + ")"
      end

    end

  end

end
