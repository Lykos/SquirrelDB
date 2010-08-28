require 'storage/exceptions/constant_exception'

module RubyDB

  module Storage

    module Constants

      PAGE_SIZE = 128 # byte
      TID_SIZE = 8 # byte
      TUPLE_NO_SIZE = 3 # byte
      TUPLE_POINTER_SIZE = 4 # byte
      HEADER_SIZE = 4 # byte
      OFFSET_SIZE = 2 # byte
      BYTE_SIZE = 8 # bit
      LENGTH_MASK = 0x7FFF
      BYTE_MASK = 0xFF

      # Check some constraints for the constants
      
      if HEADER_SIZE + (TUPLE_POINTER_SIZE + 1) * (1 << TUPLE_NO_SIZE) < PAGE_SIZE
        raise ConstantException.new(
          "With page size #{PAGE_SIZE} and tuple no size #{TUPLE_NO_SIZE}, not all tuples on a page can be adressed."
        )
      elsif (1 << OFFSET_SIZE) < PAGE_SIZE
        raise ConstantException.new(
          "With page size #{PAGE_SIZE} and offset size #{OFFSET_SIZE}, only part of the page can be used."
        )
      elsif TUPLE_POINTER_SIZE <= OFFSET_SIZE
        raise ConstantException.new(
          "The tuple pointer size has to be bigger than the offset size."
        )
      elsif TID_SIZE <= TUPLE_NO_SIZE
        raise ConstantException.new(
          "The tid size has to be bigger than the tuple no size."
        )
      elsif (1 << TUPLE_POINTER_SIZE - OFFSET_SIZE - 1) < PAGE_SIZE
        raise ConstantException.new(
          "A tuple cannot fill the whole page with this constants."
        )
      end
      
    end

  end

end
