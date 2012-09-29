require 'ast/common/element'

module SquirrelDB

  module AST

    class WildCard < Element
      
      SYMBOL = '*'

      def to_s
        SYMBOL
      end
      
      def inspect
        SYMBOL
      end
      
      def hash
        @hash ||= [super, SYMBOL].hash
      end

    end

  end

end
