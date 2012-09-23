require 'ast/iterators/rel_alg_iterator'
require 'storage/tuple'

module SquirrelDB

  module AST

    # Dummy table
    #
    class DualTable < RelAlgIterator

      def open
        super
        @start = true
      end

      def next_item
        super
        raise if @start
        Tuple.new(0)
        @start = false
      end

      def rewind
        @start = true
        super
      end
      
      def size
        1
      end
      
      def cost
        1
      end
      
    end

  end
  
end
