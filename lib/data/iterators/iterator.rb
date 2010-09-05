module RubyDB

  module Data

    class RelAlgIterator

      def initialize
        @open = false
      end

      def open?
        @open
      end

      def open
        raise if @open
      end

      def next_item
        raise unless @open
      end

      def close
        raise unless @open
      end

      def rewind
        raise unless @open
        close
        open
      end

    end

  end
  
end
