require 'data/iterators/rel_alg_iterator'

module SquirrelDB

  module Data

    class CartesianIterator < RelAlgIterator

      def initialize( left, right )
        super()
        @left = left
        @right = right
      end

      def open( state )
        super
        @left.open( state )
        @right.open( state )
        @left_item = @left.next_item
      end

      def next_item
        super
        return nil unless @left_item
        t = @right.next_item
        unless t
          @left_item = @left.next_item
          @right.rewind
          t = @right.next_item
        end
        return nil unless @left_item
        @left_item + t
      end

      def close
        super
        @left.close
        @right.close
      end

      def rewind
        super
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
