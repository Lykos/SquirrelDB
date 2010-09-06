require 'storage/tid'
require 'storage/exceptions/format_exception'
require 'storage/exceptions/address_exception'
require 'storage/exceptions/space_exception'
require 'storage/varitem_page'

module RubyDB

  module Storage

    class VarTuplePage < VaritemPage

      def initialize( page_no, content )
        super
        @moved = []
      end

      attr_reader :page_no, :content

      def moved?( tuple_no )
        @moved[tuple_no] ||= extract_int( @content[header_start( tuple_no + 1 ) - OFFSET_SIZE - 1] ) >> 7 == 1
      end

      def get_all
        (0...no_tuples).collect do |tuple_no|
          @content[get_offset( tuple_no )...get_offset( tuple_no ) + get_length( tuple_no )]
        end
      end
      
      def get_tid( tuple_no )
        check_address( tuple_no )
        raise AddressException.new( "This tuple is not moved and has no tid." ) unless moved?( tuple_no )
        @tids[tuple_no] ||= internal_get_tid( tuple_no )
      end


      def set_tid( tuple_no, new_tid )
        check_address( tuple_no )
        if new_tid.kind_of?(TID)
          new_tid = new_tid.to_raw
        end
        if new_tid.bytesize != TID_SIZE
          raise FormatException.new(
            "The new tid doesn't have the correct length."
          )
        end
        set_moved( tuple_no, true )
        set_tuple( tuple_no, new_tid )
      end

      def get_tuple( tuple_no )
        check_address( tuple_no )
        @content[get_offset( tuple_no )...get_offset( tuple_no ) + get_length( tuple_no )]
      end

      # Returns true if a new tuple with the given length fits into this page
      #
      def has_space?( new_length )
        new_length <= free_space + ITEM_HEADER_SIZE
      end

      # Returns true if the given tuple can be resized to the given size
      #
      def can_resize?( tuple_no, new_length )
        check_address( tuple_no )
        new_length <= free_space + get_length( tuple_no )
      end

      def set_tuple( tuple_no, new_content )
        check_address( tuple_no )
        set_moved( tuple_no, false )
        internal_set_tuple( tuple_no, new_content )
      end

      def add_tuple( content )
        # TODO: Removed tuples if possible
        length = content.bytesize
        unless has_space?( length )
          raise SpaceException.new( "Not enough space in page #{page_no} for this new tuple." )
        end
        tuple_no = no_tuples
        self.no_tuples = no_tuples + 1
        offset = header_start( no_tuples )
        tuple_no.times do |t|
          set_offset( t, get_offset( t ) + ITEM_HEADER_SIZE )
          offset = get_offset( t ) + get_length( t )
        end
        @content[header_start( tuple_no + 1 )...offset] = @content[header_start( tuple_no )...offset - ITEM_HEADER_SIZE]
        set_length( tuple_no, length )
        set_moved( tuple_no, false )
        set_offset( tuple_no, offset )
        @content[offset...offset + length] = content
        @free_space = free_space - length + ITEM_HEADER_SIZE
        return tuple_no
      end

      def remove_tuple( tuple_no )
        check_address( tuple_no )
        internal_set_tuple( tuple_no, "" )
        set_moved( tuple_no, false )
      end

      private

      alias :no_tuples :no_items

      alias :no_tuples= :no_items=

      def no_tuples=( new_no_tuples )
        self.no_items = new_no_tuples
      end

      def set_moved( tuple_no, bool=true )
        moved_length = get_length( tuple_no ) + ((bool ? 1 : 0) << ITEM_HEADER_SIZE - OFFSET_SIZE)
        moved_length_raw = encode_int( moved_length, ITEM_HEADER_SIZE - OFFSET_SIZE )
        @content[header_start( tuple_no )...header_start( tuple_no + 1 ) - OFFSET_SIZE] = moved_length_raw
        @moved[tuple_no] = bool
      end

      def internal_get_tid( tuple_no )
        raw_tid = get_tuple( tuple_no )
        TID.from_raw( raw_tid )
      end

      def check_address( tuple_no )
        super( tuple_no )
        if get_length( tuple_no ) == 0
          raise AddressException.new(
            "Tuple #{tuple_no} in page #{@page_no} has already been deleted."
          )
        end
      end

      def internal_set_tuple( tuple_no, new_content )
        old_tuple = get_tuple( tuple_no )
        old_length = get_length( tuple_no )
        new_length = new_content.length
        if new_length == old_length
          return if new_content == old_tuple
          @content[get_offset( tuple_no )...get_offset( tuple_no ) + old_length] = new_content
        elsif new_length > free_space + old_length
          raise SpaceException.new( "Not enough space in this page for new tuple #{tuple_no}." )
        else
          @free_space = free_space + old_length - new_length
          move_length = 0
          ((tuple_no + 1)...no_tuples).each do |t|
            set_offset( t, get_offset( t ) - old_length + new_length )
            move_length += get_length( t )
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
