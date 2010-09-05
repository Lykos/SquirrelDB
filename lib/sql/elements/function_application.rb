require 'sql/elements/syntactic_unit'

module RubyDB

  module Sql

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

      def visit( visitor )
        let_visit( visitor, @function.visit( visitor ), @parameters.collect { |p| p.visit( visitor ) } )
      end

    end

  end
  
end
