module RubyDB

  module Data

    class CartesianIterator

      def initialize( left, right )
        @left.open
        @right.open
      end

      def open
        @left.open
        @right.open
        @leftitem = @left.next_item
      end

      def next_item
        if (t = @right.next_item)
          return 
        end
      end

      def close
        @left.close
        @right.close
      end

      def rewind
        @left.rewind
        @right.rewind
      end

      def size
        @left.size * @right.size
      end

      def cost
        @left.cost * @right.cost
      end
      
    end

  end
  
end
