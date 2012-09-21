require 'sql/elements/syntactic_unit'

module SquirrelDB

  module AST

    class BinaryOperation < SyntacticUnit
    
      def initialize( operator, left, right )
        @operator = operator
        @left = left
        @right = right
      end

      attr_reader :operator, :left, :right

      def ==(other)
        super && @operator == other.operator && @left == other.left && @right == other.right
      end

      def to_s
        "(" + @left.to_s + " " + @operator.to_s + " " + @right.to_s + ")"
      end

      def inspect
        "(" + @left.inspect + " " + @operator.to_s + " " + @right.inspect + ")"
      end

      def accept( visitor )
        let_visit( visitor, @operator, @left.accept( visitor ), @right.accept( visitor ) )
      end

      def evaluate( state )
        case @operator
        when PLUS then @left.evaluate( state ) + @right.evaluate( state )
        when MINUS then @left.evaluate( state ) - @right.evaluate( state )
        when TIMES then @left.evaluate( state ) * @right.evaluate( state )
        when DIVIDED_BY then @left.evaluate( state ) / @right.evaluate( state )
        when MODULO then @left.evaluate( state ) % @right.evaluate( state )
        when POWER then @left.evaluate( state ) ** @right.evaluate( state )
        when EQUAL then @left.evaluate( state ) == @right.evaluate( state )
        when UNEQUAL then @left.evaluate( state ) != @right.evaluate( state )
        when GREATER then @left.evaluate( state ) > @right.evaluate( state )
        when GREATER_EQUAL then @left.evaluate( state ) >= @right.evaluate( state )
        when SMALLER then @left.evaluate( state ) < @right.evaluate( state )
        when SMALLER_EQUAL then @left.evaluate( state ) <= @right.evaluate( state )
        when OR then @left.evaluate( state ) || @right.evaluate( state )
        when XOR then @left.evaluate( state ) != @right.evaluate( state )
        when AND then @left.evaluate( state ) && @right.evaluate( state )
        when IMPLIES then !@left.evaluate( state ) || @right.evaluate( state )
        when IS_IMPLIED then @left.evaluate( state ) || !@right.evaluate( state )
        when EQUIVALENT then @left.evaluate( state ) == @right.evaluate( state )
        else
          raise
        end
      end

    end

  end

end
