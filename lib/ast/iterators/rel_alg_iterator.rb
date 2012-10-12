require 'ast/common/element'
require 'forwardable'

module SquirrelDB

  module AST

    class RelAlgIterator < Element

      def initialize
        @open = false
      end
      
      attr_reader :open

      extend Forwardable

      def open?
        @open
      end

      def itopen(state)
        raise if @open
        @state = state
        @open = true
      end

      def next_item
        raise "`next_item' called for #{inspect}, which is not open." unless @open
      end

      def close
        raise unless @open
        @open = false
      end

      def rewind
        raise unless @open
      end
      
      def query?
        true
      end
      
      def query(state)
        itopen(state)
        ts = []
        while t = next_item
          ts << t
        end
        close
        ts
      end

    end

  end
  
end
