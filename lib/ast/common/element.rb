module SquirrelDB

  module AST

    class Element

      def ==(other)
        self.class == other.class
      end
      
      def eql?(other)
        self == other
      end
      
      def variable?
        false
      end
      
      def hash
        @hash ||= self.class.to_s.hash
      end

    end

  end

end
