require 'ast/common/expression'

module SquirrelDB

  module AST

    class Variable < Expression

      def initialize(name, type=nil)
        super(type)
        @name = name
      end

      attr_reader :name

      def to_s
        @name
      end

      def inspect
        "Variable( #{@name} )" + type_string
      end
      
      def variable?
        true
      end

      def ==(other)
        super && @name == other.name
      end
      
      def hash
        @hash ||= [super, @name].hash
      end

    end

  end

end
