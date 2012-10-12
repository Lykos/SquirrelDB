require 'storage/constants'
require 'errors/storage_error'
require 'errors/encoding_error'

module SquirrelDB

  module Storage

    module RawUtil
      
      include Constants
      
      # Extract an unsigned integer of arbitrary length from a binary string in little Endian format.
      def extract_int(binary_string)
        raise EncodingError, "The binary string we have to extract an integer from has an invalid encoding." unless binary_string.encoding == Encoding::BINARY
        (0...binary_string.bytesize).inject(0) { |a, b| a + (binary_string.getbyte( b ) << (b * BYTE_BITS)) }
      end

      # Encode a non-negative integer into a string in little Endian format, if length is given and not 0, the string will have the given length.
      def encode_int(integer, length=0)
        raise StorageError, "Integer is negative." if integer < 0
        if length == 0
          string = ""
          while integer > 0
            string << (BYTE_MASK & integer).chr
            integer >>= BYTE_BITS
          end
        else
          raise StorageError, "#{integer} does not fit into a string of length #{length}" if int >= 1 << BYTE_BITS * length 
          string = " " * length
          length.times do |i|
            string.setbyte(i, BYTE_MASK & integer)
            integer >>= BYTE_BITS
          end
        end
        string.force_encoding(Encoding::BINARY)
      end

    end

  end

end
