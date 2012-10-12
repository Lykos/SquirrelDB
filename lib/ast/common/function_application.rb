require 'ast/common/expression'

module SquirrelDB

  module AST

    class FunctionApplication < Expression

      def initialize(variable, arguments, type=nil)
        super(type)
        @variable = variable
        @arguments = arguments
      end

      attr_reader :variable, :arguments
      
      def to_s
        @variable.to_s + "( " + @arguments.collect { |p| p.to_s }.join( "," ) + " )"
      end

      def inspect
        @variable.to_s + "( " + @arguments.collect { |p| p.inspect }.join( "," ) + " )" + type_string
      end

      def ==(other)
        super && @variable == other.variable && @arguments == other.arguments
      end
      
      def hash
        @hash ||= [super, @variable, @arguments].hash
      end
      
    end

  end
  
end
