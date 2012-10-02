require 'storage/page/item_page'
require 'errors/storage_error'

module SquirrelDB

  module Storage

    # A Page which contains items of variable length. This is only an abstract class with some private utility
    # to manage items.
    class VarItemPage < ItemPage

      protected
      
      def initialize( page_no, content )
        super
        @lengths = []
        @offsets = []
      end

      private

      def free_space
        @free_space ||= (0...no_items).inject(
          PAGE_SIZE - header_size - (ITEM_HEADER_SIZE * no_items)
        ) { |sum, e| sum - get_length(e) }
      end

      def get_offset( item_no )
        @offsets[item_no] ||= extract_int( @content[header_start( item_no + 1 ) - ITEM_OFFSET_SIZE...header_start( item_no + 1 )] )
      end

      def set_offset( item_no, new_offset )
        @offsets[item_no] = new_offset
        @content[header_start( item_no + 1 ) - ITEM_OFFSET_SIZE...header_start( item_no + 1 )] = encode_int( new_offset, ITEM_OFFSET_SIZE )
      end

      def get_length( item_no )
        @lengths[item_no] ||= extract_int( @content[header_start( item_no )...header_start( item_no + 1 ) - ITEM_OFFSET_SIZE] ) & ITEM_LENGTH_MASK
      end

      def set_length( item_no, new_length )
        @lengths[item_no] = new_length
        set_moved( item_no, moved?( item_no ) )
      end

      # Returns the starting index of a item header
      def header_start( item_no )
        header_size + item_no * ITEM_HEADER_SIZE
      end
      
    end

  end
  
end
