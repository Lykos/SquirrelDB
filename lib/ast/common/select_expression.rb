require 'ast/common/expression'

module SquirrelDB

  module AST

    class SelectExpression < Expression

      def initialize(select_statement, type=nil)
        super(type)
        @select_statement = select_statement
      end
      
      attr_reader :select_statement
      
      def hash
        @hash ||= [super, @select_statement].hash
      end

      def to_s
        "( " + @select_statement.to_s + " )"
      end

      def inspect
        "( " + @select_statement.inspect + " )" + type_string
      end

      def ==(other)
        super && @select_statement == other.select_statement
      end

    end

  end

end
