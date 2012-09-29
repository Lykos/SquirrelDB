require 'ast/rel_alg_operators/rel_alg_operator'

module SquirrelDB

  module AST

    class Projection < RelAlgOperator

      def initialize(columns, inner)
        @columns = columns
        @inner = inner
      end

      attr_reader :columns, :inner

      def to_s
        "Projection_{" + @columns.collect { |r| r.to_s }.join(", ") + "}( #{@inner.to_s} )"
      end

      def inspect
        "Projection_{" + @columns.collect { |r| r.inspect }.join(", ") + "}( #{@inner.inspect} )"
      end

      def ==(other)
        super && @columns == other.renamings && @inner == other.inner
      end
      
      def hash
        @hash ||= [super, @columns, @inner]
      end
      
    end

  end
  
end
