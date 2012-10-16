require 'ast/common/variable'

module SquirrelDB

  module AST

    class ScopedVariable < Expression

      def initialize(scope, variable, type=nil)
        super(type)
        @scope = scope
        @variable = variable
      end

      attr_reader :scope, :variable
      
      def variable?
        true
      end
      
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
