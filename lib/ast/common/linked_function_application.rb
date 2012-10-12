require 'ast/common/expression'

module SquirrelDB

  module AST

    class LinkedFunctionApplication < FunctionApplication

      def initialize(name, proc, arguments, type)
        super(name, arguments, type)
        @proc = proc
      end

      attr_reader :proc

      def ==(other)
        super &&
        @proc == other.proc
      end
      
      def hash
        @hash ||= [super, @proc].hash
      end

    end

  end
  
end
