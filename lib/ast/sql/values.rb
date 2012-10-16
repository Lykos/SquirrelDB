require 'ast/common/element'

module SquirrelDB

  module AST

    # Represents the values clause of an insert statement
    class Values < Element

      def initialize(expressions)
        @expressions = expressions
      end

      attr_reader :expressions
      
      def to_s
        "(" + expressions.collect { |v| v.to_s }.join(", ") + ")"
      end
      
      def inspect
        "(" + expressions.collect { |v| v.inspect }.join(", ") + ")"
      end
            
      def ==(other)
        super && @expressions == other.expressions
      end
      
      def hash
        @hash ||= [super, @expressions].hash
      end

    end

  end

end
