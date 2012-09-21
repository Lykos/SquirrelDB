require 'storage/exceptions/constant_exception'

module SquirrelDB

  module Storage

    module Constants

      PAGE_SIZE = 8192 # byte
      TID_SIZE = 8 # byte
      TUPLE_NO_SIZE = 3 # byte
      PAGE_NO_SIZE = TID_SIZE - TUPLE_NO_SIZE
      ITEM_HEADER_SIZE = 4 # byte
      HEADER_SIZE = 12 # byte
      TYPE_SIZE = 4 # byte
      OFFSET_SIZE = 2 # byte
      INDEX_HEADER_SIZE = 8 # byte
      BYTE_SIZE = 8 # bit
      LENGTH_MASK = 0x7FFF
      BYTE_MASK = 0xFF
      TYPE_IDS = {
        1 => :VarTuplePage,
        2 => :IndexPage,
        3 => :VarindexPage,
        4 => :TidListPage
      }

      # Check some constraints for the constants
      
      if HEADER_SIZE + (ITEM_HEADER_SIZE + 1) * (1 << (TUPLE_NO_SIZE * BYTE_SIZE)) < PAGE_SIZE
        raise ConstantException.new(
          "With page size #{PAGE_SIZE} and tuple no size #{TUPLE_NO_SIZE}, more small tuples fit on a page than can be addressed."
        )
      elsif (1 << (OFFSET_SIZE * BYTE_SIZE)) < PAGE_SIZE
        raise ConstantException.new(
          "With page size #{PAGE_SIZE} and offset size #{OFFSET_SIZE}, only part of the page can be used."
        )
      elsif ITEM_HEADER_SIZE <= OFFSET_SIZE
        raise ConstantException.new(
          "The tuple pointer size has to be bigger than the offset size."
        )
      elsif TID_SIZE <= TUPLE_NO_SIZE
        raise ConstantException.new(
          "The tid size has to be bigger than the tuple no size."
        )
      elsif (1 << (BYTE_SIZE * (ITEM_HEADER_SIZE - OFFSET_SIZE) - 1)) < PAGE_SIZE
        raise ConstantException.new(
          "A tuple cannot fill the whole page with this constants."
        )
      elsif TYPE_IDS.any? { |id, type| id > 1 << TYPE_SIZE * BYTE_SIZE }
        raise ConstantException.new(
          "Not all types can be represented with this type size."
        )
      elsif INDEX_HEADER_SIZE <= PAGE_NO_SIZE
        raise ConstantException.new(
          "The index header can't point to the upper index page and include the level."
        )
      elsif HEADER_SIZE < TUPLE_NO_SIZE + PAGE_NO_SIZE + TYPE_SIZE
        raise ConstantException.new(
          ""
        )
      end
      
    end

  end

end
