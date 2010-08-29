module RubyDB

  module SQL

    module BinaryOperation
    
      def initialize( operator, left, right )
        @operator = operator
        @left = left
        @right = right
      end

      attr_reader :operator, :left, :right

    end

  end

end
