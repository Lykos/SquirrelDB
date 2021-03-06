require 'ast/common/variable'

module SquirrelDB

  module AST

    class Renaming < Element

      def initialize( expression, name )
        @expression = expression
        @name = name
      end

      attr_reader :expression, :name

      def to_s
        @expression.to_s + " as " + @name.to_s
      end

      def inspect
        @expression.inspect + " as " + @name.inspect
      end

      def ==(other)
        super && @expression == other.expression && @name == other.name
      end
      
      def hash
        @hash ||= [super, @expression, @name].hash
      end
      
    end

  end

end
