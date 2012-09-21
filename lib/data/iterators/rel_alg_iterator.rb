require 'forwardable'

module SquirrelDB

  module Data

    class RelAlgIterator

      def initialize
        @open = false
      end

      extend Forwardable

      def open?
        @open
      end

      def open( state )
        raise if @open
        @state = state
      end

      def next_item
        raise unless @open
      end

      def close
        raise unless @open
      end

      def rewind
        raise unless @open
      end

      def evaluate( state )
        open(state)
        res = next_item
        raise unless res
        raise if next_item
        close
        res.length == 1 ? res[0] : res
      end

    end

  end
  
end
