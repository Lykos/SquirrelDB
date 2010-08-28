module Storage

  class TID

    def self.from_raw( raw_tid )
      raise unless raw_tid.length == TID_SIZE
      page_no = extract_int( raw_tid[0...TID_SIZE - TUPLE_NO_SIZE] )
      tuple_no = extract_int( raw_tid[TID_SIZE - TUPLE_NO_SIZE...TID_SIZE] )
      new( page_no, tuple_no )
    end

    def initialize( page_no, tuple_no )
      @page_no = page_no
      @tuple_no = tuple_no
    end

    attr_reader :page_no, :tuple_no

    def <=>( other )
      r = @page_no <=> other.page_no
      if r == 0
        @tuple_no <=> other.tuple_no
      else
        r
      end
    end

    def to_raw
      encode_int( @page_no, TID_SIZE - TUPLE_NO_SIZE ) + encode_int( @tuple_no, TUPLE_NO_SIZE )
    end

  end

end
