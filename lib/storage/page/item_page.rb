require 'page'

module RubyDB

  module Storage

    class ItemPage < Page

      private

      def no_items
        @no_items ||= extract_int( @content[1...HEADER_SIZE] )
      end

      def no_items=( new_no_items )
        @no_items = new_no_items
        @content[TYPE_SIZE...HEADER_SIZE] = encode_int( @no_items, HEADER_SIZE - TYPE_SIZE )
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

    end

  end

end
