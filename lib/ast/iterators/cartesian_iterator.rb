require 'ast/iterators/rel_alg_iterator'

module SquirrelDB

  module AST

    class CartesianIterator < RelAlgIterator

      def initialize(left, right)
        super()
        @left = left
        @right = right
      end
      
      attr_reader :left, :right
      
      def ==(other)
        super && @left == other.left && @right == other.right
      end
      
      def schema
        @schema ||= @left.schema + @right.schema
      end
      
      def inspect
        "CartesianIterator(#{@left.inspect}, #{@right.inspect})"
      end
      
      def to_s
        "CartesianIterator(#{@left.to_s}, #{@right.to_s})"
      end
      
      def hash
        @hash ||= [super, @left, @right].hash
      end

      def itopen( state )
        super
        @left.itopen( state )
        @right.itopen( state )
        @left_item = @left.next_item
        @right_empty = false
      end

      def next_item
        super
        return nil if @left_item.nil? || @right_empty
        right_item = @right.next_item
        unless right_item
          @left_item = @left.next_item
          return nil if @left_item.nil?
          @right.rewind
          right_item = @right.next_item
          if right_item.nil?
            # If this is nil, then the right iterator is empty and everything will be nil
            @right_empty = true
            return nil
          end
        end
        @left_item + right_item
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
        @left_item = @left.next_item
      end
      
    end

  end
  
end
