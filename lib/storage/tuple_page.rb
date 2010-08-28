require 'constants'
require 'tid'
require 'util'

module Storage

  class TuplePage

    include Constants

    def initialize( page_no, content )
      @page_no = page_no
      @content = content[0...PAGE_SIZE].ljust(PAGE_SIZE, "\0")
      @lengths = []
      @moved = []
      @offsets = []
    end

    attr_reader :page_no, :content, :free_space

    include Util

    def moved?( tuple_no )
      @moved[tuple_no] ||= extract_int( @content[tuple_start( tuple_no + 1 ) - OFFSET_SIZE - 1] ) >> 7 == 1
    end

    def get_tid( tuple_no )
      raise "This page is not moved and has no tid." unless moved?( tuple_no )
      @tids[tuple_no] ||= internal_get_tid( tuple_no )
    end

    def set_tid( tuple_no, new_tid )
      if new_tid.kind_of?(TID)
        new_tid = new_tid.to_raw
      end
      raise unless new_tid.length == TID_SIZE
      set_moved( tuple_no, true )
      set_tuple( tuple_no, new_tid )
    end

    def get_tuple( tuple_no )
      raise if tuple_no > no_tuples
      @content[get_offset( tuple_no )...get_offset( tuple_no ) + get_length( tuple_no )]
    end

    def free_space
      @free_space ||= (0...no_tuples).inject(
        PAGE_SIZE - HEADER_SIZE - (TUPLE_POINTER_SIZE * no_tuples)
      ) { |sum, e| sum + get_length( e ) }
    end

    def set_tuple( tuple_no, new_content )
      raise if tuple_no > no_tuples
      raise "This tuple has already been deleted." if get_length( tuple_no ) == 0
      internal_set_tuple( tuple_no, new_content )
    end

    def add_tuple( content )
      # TODO: Moved tuples if possible
      length = content.length
      raise "Not enough space in this page for new tuple." if length + TUPLE_POINTER_SIZE > free_space
      tuple_no = no_tuples
      self.no_tuples = no_tuples + 1
      offset = tuple_start( no_tuples )
      tuple_no.times do |t|
        set_offset( t, get_offset( t ) + TUPLE_POINTER_SIZE )
        offset = get_offset( t ) + get_length( t )
      end
      @content[tuple_start( tuple_no + 1 )...offset] = @content[HEADER_SIZE + TUPLE_POINTER_SIZE * tuple_no...offset - TUPLE_POINTER_SIZE]
      set_length( tuple_no, length )
      set_moved( tuple_no, false )
      set_offset( tuple_no, offset )
      @content[offset...offset + length] = content
      @free_space -= length + TUPLE_POINTER_SIZE
      return tuple_no
    end

    def remove_tuple( tuple_no )
      raise if tuple_no > no_tuples
      set_tuple( tuple_no, "" )
      set_moved( tuple_no, false )
    end

    private

    def get_offset( tuple_no )
      raise if tuple_no > no_tuples
      @offsets[tuple_no] ||= extract_int( @content[tuple_start( tuple_no + 1 ) - OFFSET_SIZE...tuple_start( tuple_no + 1 )] )
    end

    def set_offset( tuple_no, new_offset )
      raise if tuple_no > no_tuples
      @offsets[tuple_no] = new_offset
      @content[tuple_start( tuple_no + 1 ) - OFFSET_SIZE...tuple_start( tuple_no + 1 )] = encode_int( new_offset, OFFSET_SIZE )
    end

    def set_length( tuple_no, new_length )
      raise if tuple_no > no_tuples
      @lengths[tuple_no] = new_length
      set_moved( tuple_no, moved?( tuple_no ) )
    end

    def get_length( tuple_no )
      raise if tuple_no > no_tuples
      @lengths[tuple_no] ||= extract_int( @content[tuple_start( tuple_no )...tuple_start( tuple_no + 1 ) - OFFSET_SIZE] ) & LENGTH_MASK
    end

    def set_moved( tuple_no, bool=true )
      moved_length = get_length( tuple_no ) + ((bool ? 1 : 0) << TUPLE_POINTER_SIZE - OFFSET_SIZE)
      moved_length_raw = encode_int( moved_length, TUPLE_POINTER_SIZE - OFFSET_SIZE )
      @content[tuple_start( tuple_no )...tuple_start( tuple_no + 1 ) - OFFSET_SIZE] = moved_length_raw
      @moved[tuple_no] = bool
    end

    # Returns the starting index of a tuple header
    #
    def tuple_start( tuple_no )
      HEADER_SIZE + tuple_no * TUPLE_POINTER_SIZE
    end

    def internal_get_tid( tuple_no )
      raw_tid = get_tuple( tuple_no )
      TID.from_raw( raw_tid )
    end

    def no_tuples
      @no_tuples ||= extract_int( @content[1...HEADER_SIZE] )
    end

    def no_tuples=( new_no_tuples )
      @no_tuples = new_no_tuples
      @content[1...HEADER_SIZE] = encode_int( @no_tuples, HEADER_SIZE - 1 )
    end

    def internal_set_tuple( tuple_no, new_content )
      raise if tuple_no > no_tuples
      old_tuple = get_tuple( tuple_no )
      old_length = get_length( tuple_no )
      new_length = new_content.length
      if new_length == old_length
        return if new_content == old_tuple
        @content[get_offset( tuple_no )...get_offset( tuple_no ) + old_length]
      elsif new_length > free_space + old_length
        raise "Not enough space in this page for new tuple " + tuple_no
      else
        @free_space = free_space + old_length - new_length
        move_length = 0
        ((tuple_no + 1)...no_tuples).each do |t|
          new_offset = get_offset( t ) - old_length + new_length
          @offsets[t] = new_offset
          @content[HEADER_SIZE + TUPLE_POINTER_SIZE * (t + 1) - OFFSET_SIZE...HEADER_SIZE + TUPLE_POINTER_SIZE * (t + 1)] = encode_int( new_offset, OFFSET_SIZE )
          move_length += get_length( t )
        end
        offset = get_offset( tuple_no )
        if move_length > 0
          old_after = offset + old_length
          new_after = offset + new_length
          @content[new_after...new_after + move_length] = @content[old_after...new_after + move_length]
        end
        @content[offset...new_after] = new_content
        @lengths[tuple_no] = new_length
        @content[HEADER_SIZE + TUPLE_POINTER_SIZE * tuple_no...HEADER_SIZE + TUPLE_POINTER_SIZE * (tuple_no + 1) - OFFSET_SIZE] = encode_int( new_length, TUPLE_POINTER_SIZE - OFFSET_SIZE )
      end
    end

  end
  
end
