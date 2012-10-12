require 'ast/common/expression'

module SquirrelDB

  module AST

    class LinkedVariable < Expression

      def initialize(variable, offset)
        @variable = variable
        @offset = offset
      end

      attr_reader :variable, :offset

      def to_s
        @variable.to_s
      end
      
      def inspect
        "LinkedVariable( #{@name}, #{offset} )" + type_string
      end
      
      def variable?
        true
      end

      def ==(other)
        super && @variable == other.variable && @offset == other.offset
      end
      
      def hash
        @hash ||= [super, @variable, @offset].hash
      end

    end

  end

end
