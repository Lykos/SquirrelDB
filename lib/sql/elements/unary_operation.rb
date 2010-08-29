module RubyDB

  module SQL

    module UnaryOperation

      def initialize( operator, inner )
        @operator = operator
        @inner = inner
      end

      attr_reader :operator, :inner

    end

  end

end
