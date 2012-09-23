require 'ast/common/element'
require 'forwardable'

module SquirrelDB

  module AST

    class RelAlgIterator < Element

      def initialize
        @open = false
      end

      extend Forwardable

      def open?
        @open
      end

      def itopen( state )
        raise if @open
        @state = state
        @open = true
      end

      def next_item
        raise unless @open
      end

      def close
        raise unless @open
        @open = false
      end

      def rewind
        raise unless @open
      end

      def evaluate( state )
        self.itopen(state)
        res = next_item
        raise unless res
        raise if next_item
        close
        res
      end

    end

  end
  
end
