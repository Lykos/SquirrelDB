require 'storage/raw_util'
require 'storage/constants'
require 'storage/exceptions/format_exception'

module RubyDB

  module Storage

    class TID

      extend RawUtil
      include RawUtil

      def self.from_raw( raw_tid )
        unless raw_tid.bytesize == TID_SIZE
          raise FormatException.new(
            "The length of the raw tid was #{raw_tid.bytesize} instead of #{TID_SIZE}."
          )
        end
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

end
