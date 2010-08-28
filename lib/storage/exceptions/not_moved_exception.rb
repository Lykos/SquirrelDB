require 'storage/exceptions/storage_exception'

module RubyDB

  module Storage

    class NotMovedException < StorageException

      def initialize( tuple_no=nil, page_no=nil )
        if page_no
          super( "Tuple (#{page_no} ,#{tuple_no}) has not been moved and has no TID as value." )
        elsif tuple_no
          super( "Tuple #{tuple_no} has not been moved and has no TID as value." )
        else
          super( "A tuple which has not been moved has no TID as value." )
        end
      end
      
    end

  end
  
end
