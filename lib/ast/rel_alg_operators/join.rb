require 'ast/rel_alg_operators/rel_alg_operator'

module SquirrelDB

  module AST

    class Join < RelAlgOperator

      def initialize( expression, left, right )
        @expression = expression
        @left = left
        @right = right
      end

      attr_reader :expression, :left, :right
 
      def ==(other)
        (other.class == Join || other.class == Cartesian) && @expression == other.expressoin && @left == other.left && @right == other.right
      end
      
      def inspect
        "Join_{#{@expression.to_s}}(#{@left.inspect}, #{@right.inspect})"
      end
      
      def to_s
        "Join_{#{@expression.to_s}}(#{@left.to_s}, #{@right.to_s})"
      end
      
      def hash
        @hash ||= [@expression, @left, @right].hash
      end

    end

  end

end
