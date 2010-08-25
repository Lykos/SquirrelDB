# To change this template, choose Tools | Templates
# and open the template in the editor.

module Storage

  class Page

    TID_SIZE = 8 # byte
    OFFSET_SIZE = 3 # byte
    HEADER_SIZE = 4 # byte
    BYTE_SIZE = 8

    def initialize( page_no, content )
      @page_no = page_no
      @content = content
      @lengths = []
      @moveds = []
      @offsets = []
      @listeners = []
    end

    attr_reader :page_no, :content

    def add_listener( listener )
      @listeners.push( listener )
    end

    def remove_listener( listener )
      @listeners.delete( listener )
    end


    def moved?( tuple_no )
      @moveds[tuple_no] ||= @content[HEADER_SIZE + TID_SIZE * tuple_no] >> 7
    end

    def extract_int( binary_string )
      (0...binary_string.length).inject(0) { |a, b| a + binary_string[b] << (b * BYTE_SIZE) }
    end

    def tid_of( tuple_no )
      @tids[tuple_no] ||= extract_int( @content[HEADER_SIZE + TID_SIZE * tuple_no...HEADER_SIZE + TID_SIZE * (tuple_no + 1)] )
    end

    def get_tuple( tuple_no )
      @content[offset_of( tuple_no )..offset_of( tuple_no ) + length_of( tuple_no )]
    end

    def no_tuples
      @no_tuples ||= extract_int( @content[1...HEADER_SIZE] )
    end

    def free_space( tuple_no )
      @free_space ||= (0...no_tuples).inject(
        PAGE_SIZE - HEADER_SIZE - (TID_SIZE * no_tuples)
      ) { |e| free_space -= length_of( e ) }
    end

    def set_tuple( tuple_no, new_content )
      old_tuple = get_tuple( tuple_no )
      old_length = length_of( tuple_no )
      new_length = new_content.length
      if new_length == old_length
        return if new_content == old_tuple
        @content[offset_of( tuple_no )...offset_of( tuple_no ) + old_length]
        @change_listeners.each { |l| l.notify( self ) }
      elsif new_length > free_space + old_length
        raise "Not enough space in this page for new tuple " + tuple_no
      else
        @freespace = free_space + old_length - new_length
        move_length = 0
        ((tuple_no + 1)...tuples).each do |t|
          next if moved?( t )
          @offsets[t] = offset_of( t ) - old_length + new_length
          move_length += length_of( t )
        end
        offset = offset_of( tuple_no )
        if move_length > 0
          old_after = offset + old_length
          new_after = offset + new_length
          @content[new_after...new_after + move_length] = @content[old_after...new_after + move_length]
        end
        @content[offset...new_after] = new_content
        @lengths[tuple_no] = new_length
        @change_listeners.each { |l| l.notify( self ) }
      end
    end

    def add_tuple( content )
      length = content.length
      if length > free_space
        raise "Not enough space in this page for new tuple."
      end
      tuples += 1
    end

    def offset_of( tuple_no )
      @offsets[tuple_no] ||= extract_int( @content[HEADER_SIZE + TID_SIZE * (tuple_no + 1) - OFFSET_SIZE...HEADER_SIZE + TID_SIZE * (tuple_no + 1)] )
    end

    def length_of( tuple_no )
      @lengths[tuple_no] ||= extract_int( @content[HEADER_SIZE + TID_SIZE * tuple_no...HEADER_SIZE + TID_SIZE * (tuple_no + 1) - OFFSET_SIZE])
    end

  end
  
end
