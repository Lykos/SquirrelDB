require 'storage/page/page'

module SquirrelDB

  module Storage

    # A page that contains several items. This is only an abstract class with some private utility
    # to manage items.
    class ItemPage < Page
      
      # Returns the length of the header of this page type
      def header_size
        super + TID_SIZE
      end

      # Returns true if the content of this page continues somewhere else 
      def has_next_page?
        internal_next_page != 0
      end

      # Returns the page_no of the next page, raises a +StorageError+ if there is no next page.
      def next_page
        raise StorageError, "The 0th page can never be the next page." unless has_next_page?
        internal_next_page
      end

      # Returns the number of items on this page
      def no_items
        @no_items ||= extract_int( @content[TYPE_SIZE + PAGE_NO_SIZE...TYPE_SIZE + TID_SIZE] )
      end
              
      # Inits an empty page.
      def init_empty
        super
        no_items = 0
      end

      private

      def internal_next_page
        @next_page ||= extract_int( @content[TYPE_SIZE...TYPE_SIZE + PAGE_NO_SIZE] )
      end

      def no_items=(new_no_items)
        @no_items = new_no_items
        @content[TYPE_SIZE + PAGE_NO_SIZE...TYPE_SIZE + TID_SIZE] = encode_int( @no_items, TUPLE_NO_SIZE )
      end

      def check_address( item_no )
        if item_no > no_items
          raise StorageError.new(
            "There are only #{no_items} items in page #{@page_no}. Item #{item_no} can't be accessed."
          )
        elsif item_no < 0
          raise StorageError.new(
            "Negative item numbers are not allowed."
          )
        end
      end

    end

  end

end
