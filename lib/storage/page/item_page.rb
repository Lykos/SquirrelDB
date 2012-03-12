require 'page'

module RubyDB

  module Storage

    class ItemPage < Page

      def next_page=
        @next_page ||= extract_int( @content[TYPE_SIZE...TYPE_SIZE + PAGE_NO_SIZE] )
      end

      def has_next_page?
        internal_next_page != 0
      end

      def next_page
        raise AddressException.new( "The 0th page can never be the next page." ) unless has_next_page?
        internal_next_page
      end

      def no_items
        @no_items ||= extract_int( @content[TYPE_SIZE + PAGE_NO_SIZE...TYPE_SIZE + TID_SIZE] )
      end
      
      private

      def internal_next_page
        @next_page ||= extract_int( @content[TYPE_SIZE...TYPE_SIZE + PAGE_NO_SIZE] )
      end


      def no_items=( new_no_items )
        @no_items = new_no_items
        @content[TYPE_SIZE + PAGE_NO_SIZE...TYPE_SIZE + TID_SIZE] = encode_int( @no_items, TUPLE_NO_SIZE )
      end

      def check_address( item_no )
        if item_no > no_items
          raise AddressException.new(
            "There are only #{no_items} items in page #{@page_no}. Item #{item_no} can't be accessed."
          )
        elsif item_no < 0
          raise AddressException.new(
            "Negative item numbers are not allowed."
          )
        end
      end

      def init_empty
        super
        no_items = 0
      end

    end

  end

end
