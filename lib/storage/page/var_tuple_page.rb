require 'storage/tid'
require 'errors/storage_error'
require 'storage/page/var_item_page'

module SquirrelDB

  module Storage

    class VarTuplePage < VarItemPage

      def initialize( page_no, content )
        super
        @moved = []
      end

      attr_reader :page_no, :content

      def moved?(tuple_no)
        @moved[tuple_no] ||= extract_int( @content[header_start( tuple_no + 1 ) - ITEM_OFFSET_SIZE - 1] ) & ITEM_MOVED_MASK != 0
      end

      def get_tid(tuple_no)
        check_address(tuple_no)
        unless moved?( tuple_no )
          raise StorageError, "This tuple is not moved and contains no tid."
        end  
        @tids[tuple_no] ||= internal_get_tid( tuple_no )
      end

      def set_tid(tuple_no, new_tid)
        check_address( tuple_no )
        if new_tid.kind_of?(TID)
          new_tid = new_tid.to_raw
        end
        if new_tid.bytesize != TID_SIZE
          raise StorageError, "The new tid doesn't have the correct length."
        end
        set_moved( tuple_no, true )
        set_tuple( tuple_no, new_tid )
      end

      def get_tuple(tuple_no)
        check_address(tuple_no)
        @content[get_offset(tuple_no)...get_offset(tuple_no) + get_length(tuple_no)]
      end

      # Returns true if a new tuple with the given length fits into this page
      #
      def has_space?(new_length)
        new_length <= free_space + ITEM_HEADER_SIZE
      end

      # Returns true if the given tuple can be resized to the given size
      #
      def can_resize?(tuple_no, new_length)
        check_address(tuple_no)
        new_length <= free_space + get_length(tuple_no)
      end

      def set_tuple( tuple_no, new_content )
        check_address( tuple_no )
        set_moved( tuple_no, false )
        internal_set_tuple( tuple_no, new_content )
      end

      # Add the +String+ +content+ as a tuple. If not enough space is available, a +StorageError+ is thrown.
      def add_tuple(content)
        # TODO Reuse removed tuples if possible
        length = content.bytesize
        unless has_space?(length)
          raise StorageError, "Not enough space in page #{page_no} for this new tuple."
        end
        tuple_no = no_tuples
        self.no_tuples = no_tuples + 1
        offset = header_start(no_tuples)
        tuple_no.times do |t|
          set_offset(t, get_offset(t) + ITEM_HEADER_SIZE)
          offset = get_offset( t ) + get_length( t )
        end
        @content[header_start( tuple_no + 1 )...offset] = @content[header_start( tuple_no )...offset - ITEM_HEADER_SIZE]
        set_length(tuple_no, length)
        set_moved(tuple_no, false)
        set_offset(tuple_no, offset)
        @content[offset...offset + length] = content
        @free_space = free_space - length + ITEM_HEADER_SIZE
        return tuple_no
      end

      def remove_tuple( tuple_no )
        check_address( tuple_no )
        internal_set_tuple( tuple_no, "" )
        set_moved( tuple_no, false )
      end

      alias :no_tuples :no_items

      private

      alias :no_tuples= :no_items=

      def no_tuples=( new_no_tuples )
        self.no_items = new_no_tuples
      end

      def set_moved( tuple_no, bool=true )
        moved_length = get_length( tuple_no ) + ((bool ? 1 : 0) << ITEM_HEADER_SIZE - ITEM_OFFSET_SIZE)
        moved_length_raw = encode_int( moved_length, ITEM_HEADER_SIZE - ITEM_OFFSET_SIZE )
        @content[header_start( tuple_no )...header_start( tuple_no + 1 ) - ITEM_OFFSET_SIZE] = moved_length_raw
        @moved[tuple_no] = bool
      end

      def internal_get_tid( tuple_no )
        raw_tid = get_tuple( tuple_no )
        TID.from_raw( raw_tid )
      end

      def check_address( tuple_no )
        super( tuple_no )
        if get_length( tuple_no ) == 0
          raise StorageError, "Tuple #{tuple_no} in page #{@page_no} has already been deleted."
        end
      end

      def internal_set_tuple(tuple_no, new_content)
        old_tuple = get_tuple(tuple_no)
        old_length = get_length(tuple_no)
        new_length = new_content.length
        if new_length == old_length
          return if new_content == old_tuple
          @content[get_offset( tuple_no )...get_offset( tuple_no ) + old_length] = new_content
        elsif new_length > free_space + old_length
          raise StorageError, "Not enough space in this page for new tuple #{tuple_no}."
        else
          @free_space = free_space + old_length - new_length
          move_length = 0
          ((tuple_no + 1)...no_tuples).each do |t|
            set_offset(t, get_offset(t) - old_length + new_length)
            move_length += get_length(t)
          end
          offset = get_offset( tuple_no )
          old_after = offset + old_length
          new_after = offset + new_length
          if move_length > 0
            @content[new_after...new_after + move_length] = @content[old_after...old_after + move_length]
          end
          @content[offset...new_after] = new_content
          set_length( tuple_no, new_length )
        end
      end

    end

  end
  
end
