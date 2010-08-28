require 'constants'

module Storage

  include Constants

  module Util

    def extract_int( binary_string )
      (0...binary_string.length).inject(0) { |a, b| a + (binary_string.getbyte( b ) << (b * BYTE_SIZE)) }
    end

    def encode_int( integer, length )
      string = " " * length
      int = integer
      length.times do |i|
        string.setbyte( i, BYTE_MASK & int )
        int >>= BYTE_SIZE
      end
      raise "#{integer} does not fit into a string of length #{length}" if int > 0
      string
    end

  end

end
