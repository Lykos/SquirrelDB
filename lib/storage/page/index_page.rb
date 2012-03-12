require 'format_exception'
require 'space_exception'

module RubyDB
  
  module Storage

    # Represents an index with fixed length items
    #
    class IndexPage < Page

      def initialize( page_no, content, item_size )
        super( page_no, content )
        @item_size = item_size
      end

      def get_item( item_no )
        check_address( item_no )
        @content[item_start( item_no )...tid_start( item_no + 1)]
      end

      def set_item( item_no, new_item )
        check_address( item_no )
        if new_item.bytesize != @item_size
          raise FormatException.new(
            "New version of item #{item_no} does not have size #{@item_size}"
          )
        end
        @content[item_start( item_no )...tid_start( item_no + 1)] = new_item
      end

      def get_tid( tid_no )
        check_tid_address( tid_no )
        @content[tid_start( tid_no )...item_start( tid_no )]
      end

      def set_tid( tid_no, new_tid )
        check_tid_address( tid_no )
        @content[tid_start( tid_no )...item_start( tid_no )] = new_tid
      end

      def split_tid( tid_no, item, left_tid, right_tid )
        check_tid_address( tid_no )
        if free_space < @item_size + TID_SIZE
          raise SpaceException.new(
            "There is not enough space to split the tid #{tid_no} in index page #{@page_no}."
          )
        end
        @content[item_start(tid_no + 1)...end_content + @item_size + TID_SIZE] = @content[item_start( tid_no )...end_content]
        self.free_space = self.free_space - @item_size - TID_SIZE
        self.no_items = no_items + 1
        set_tid( tid_no, left_tid )
        set_item( tid_no, item )
        set_tid( tid_no + 1, right_tid )
      end

      # Merges the given tid with the next one
      #
      def merge_tids( tid_no, new_tid )
        check_tid_address( tid_no )
        check_tid_address( tid_no + 1 )
        set_tid( tid_no, new_tid )
        @content[item_start( tid_no )...content_end - @item_size - TID_SIZE] = @content[item_start( tid_no + 1 )...end_content]
        self.free_space = self.free_space + @item_size + TID_SIZE
        self.no_items = no_items - 1
      end

      private

      def free_space
        @free_space ||= PAGE_SIZE - content_end
      end

      def content_end
        item_start( no_items + 1 )
      end

      def item_start( item_no )
        HEADER_SIZE + INDEX_HEADER_SIZE + item_no * @item_size + (item_no + 1) * TID_SIZE
      end

      def tid_start( tid_no )
        HEADER_SIZE + INDEX_HEADER_SIZE + tid_no * @item_size + tid_no * TID_SIZE
      end

      def check_tid_address( tid_no )
        return if tid_no == 0
        check_address( tid_no - 1 )
      end

      def level
        @level ||= extract_int( @content[HEADER_SIZE + TID_SIZE - TUPLE_NO_SIZE...HEADER_SIZE + INDEX_HEADER_SIZE] )
      end

      def level=( new_level )
        @level = new_level
        raw_level = encode_int( @content[INDEX_HEADER_SIZE - TUPLE_NO_SIZE] )
        @content[HEADER_SIZE + TID_SIZE - TUPLE_NO_SIZE...HEADER_SIZE + INDEX_HEADER_SIZE] = raw_level
      end

      def parent
        @parent ||= extract_int( @content[HEADER_SIZE...HEADER_SIZE + TID_SIZE - TUPLE_NO_SIZE] )
      end

      def parent=( new_parent )
        @parent = new_parent
        raw_parent = encode_int( new_parent, TID_SIZE - TUPLE_NO_SIZE )
        @content[HEADER_SIZE...HEADER_SIZE + TID_SIZE - TUPLE_NO_SIZE] = raw_parent
      end
      
    end

  end
  
end
