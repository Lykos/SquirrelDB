require 'errors/storage_exception'
require 'data/constants'

module SquirrelDB

  module Storage

    module Constants
      
      # Bits of a byte
      BYTE_SIZE = 8

      # Size of a page that is always read and written at once in bytes
      PAGE_SIZE = 8192
      
      # Length of the tuple no inside a page in bytes (part of the TID)
      TUPLE_NO_SIZE = 2
      
      # Length of the tuple no inside a page in bytes (part of the TID)
      PAGE_NO_SIZE = 6

      # Length of a Tuple ID in bytes
      TID_SIZE = 8
      
      # Length of the offset of an item in bytes (part of the item header)
      ITEM_OFFSET_SIZE = 2
      
      # Length of the length of an item in bytes (part of the item header)
      ITEM_LENGTH_SIZE = 2

      # Mask to extract the length of an item
      ITEM_LENGTH_MASK = (1 << (ITEM_OFFSET_SIZE * BYTE_SIZE - 1)) - 1

      # Mask to extract a nonzero value if the item is moved
      ITEM_MOVED_MASK = (1 << (ITEM_OFFSET_SIZE * BYTE_SIZE - 1))
      
      # Length of the header of an item in a page in bytes
      ITEM_HEADER_SIZE = ITEM_OFFSET_SIZE + ITEM_LENGTH_SIZE
      
      # Length of the part, where the page type is stored in bytes
      TYPE_SIZE = 2
      
      # Mask to extract a byte
      BYTE_MASK = (1 << BYTE_SIZE) - 1
      
      # Type ids of the types
      TYPES_IDS = {
        :TuplePage => 1,
        :VarTuplePage =>2,
        :IndexPage => 3,
        :MetaDataPage => 4,
      }
      
      # Inverse map to get the types from the type ids.
      IDS_TYPES = TYPES_IDS.invert

      # Check some constraints for the constants
      if (ITEM_HEADER_SIZE + 1) * (1 << (TUPLE_NO_SIZE * BYTE_SIZE)) < PAGE_SIZE
        raise StorageError, "With page size #{PAGE_SIZE} and tuple no size #{TUPLE_NO_SIZE}, more small tuples fit on a page than can be addressed."
      elsif (1 << (ITEM_OFFSET_SIZE * BYTE_SIZE)) < PAGE_SIZE
        raise StorageError, "With page size #{PAGE_SIZE} and offset size #{ITEM_OFFSET_SIZE}, only part of the page can be used."
      elsif ITEM_HEADER_SIZE <= ITEM_OFFSET_SIZE
        raise StorageError, "The item header size has to be bigger than the item offset size."
      elsif ITEM_HEADER_SIZE <= ITEM_LENGTH_SIZE
        raise StorageError, "The item header size has to be bigger than the item length size."
      elsif TID_SIZE <= TUPLE_NO_SIZE
        raise StorageError, "The tid size has to be bigger than the tuple no size."
      elsif (1 << (BYTE_SIZE * (ITEM_HEADER_SIZE - ITEM_OFFSET_SIZE) - 1)) < PAGE_SIZE
        raise StorageError, "A tuple could never fill the whole page with these constants."
      elsif TYPES_IDS.any? { |type, id| id >= 1 << TYPE_SIZE * BYTE_SIZE }
        raise StorageError, "Not all page types can be represented with this type size."
      end
      
    end

  end

end
