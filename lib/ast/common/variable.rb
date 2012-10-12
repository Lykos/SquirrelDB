require 'ast/common/expression'

module SquirrelDB

  module AST

    class Variable < Expression

      def initialize(name)
        @name = name
      end

      attr_reader :name

      def to_s
        @name
      end

      def inspect
        @name
      end
      
      def variable?
        true
      end

      def ==(other)
        super && @name == other.name
      end
      
      def to_s
        @name
      end
      
      def inspect
        "Variable(" + @name + ")"
      end
      
      def hash
        @hash ||= [super, @name].hash
      end

    end

  end

end
