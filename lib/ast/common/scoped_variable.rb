require 'ast/common/variable'

module SquirrelDB

  module AST

    class ScopedVariable < Variable

      def initialize(scope, variable)
        @scope = scope
        @variable = variable
        super(to_s)
      end

      attr_reader :scope, :variable
      
      def to_s
        @scope.to_s + "." + @variable.to_s
      end

      def inspect
        "ScopedVariable( " + @scope.inspect + "." + @variable.inspect + " )" + type_string
      end

      def ==(other)
        super && @scope == other.scope && @variable == other.variable
      end
      
      def hash
        @hash ||= [super, @scope, @variable].hash
      end

    end

  end

end
