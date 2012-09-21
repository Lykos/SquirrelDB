require 'sql/elements/syntactic_unit'

module SquirrelDB

  module AST

    class FunctionApplication < SyntacticUnit

      def initialize( function, parameters )
        @function = function
        @parameters = parameters
      end

      attr_reader :function, :parameters

      def to_s
        @function.to_s + "( " + @parameters.collect { |p| p.to_s }.join( "," ) + " )"
      end

      def inspect
        @function.to_s + "( " + @parameters.collect { |p| p.inspect }.join( "," ) + " )"
      end

      def ==(other)
        super && @function == other.function && @parameters == other.parameters
      end

      def accept( visitor )
        let_visit( visitor, @function.accept( visitor ), @parameters.collect { |p| p.accept( visitor ) } )
      end

      def evaluate( state )
        state.get_function( @function ).call( *@parameters )
      end

    end

  end
  
end
