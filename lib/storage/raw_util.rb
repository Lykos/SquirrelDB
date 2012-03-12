require 'storage/constants'
require 'storage/exceptions/format_exception'

module RubyDB

  module Storage

    module RawUtil

      include Constants

      def extract_int( binary_string )
        (0...binary_string.bytesize).inject(0) { |a, b| a + (binary_string.getbyte( b ) << (b * BYTE_SIZE)) }
      end

      def encode_int( integer, length )
        string = " " * length
        int = integer
        length.times do |i|
          string.setbyte( i, BYTE_MASK & int )
          int >>= BYTE_SIZE
        end
        raise FormatException.new( "#{integer} does not fit into a string of length #{length}" ) if int > 0
        string
      end

    end

  end

end
