require 'storage/exceptions/storage_exception'
require 'storage/constants'

module RubyDB

  module Storage
    
    class PageSizeException < StorageException

      include Constants

      def initialize( actual_length=nil )
        message = "Page size is #{PAGE_SIZE}"
        if actual_length
          message += ", page with size #{actual_length} not allowed"
        end
        super( message + "." )
      end
      
    end

  end
  
end
