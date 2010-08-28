require 'storage/exceptions/storage_exception'

module RubyDB

  module Storage

    class SpaceException < StorageException

      def initialize( actual=nil, needed=nil )
        message = "not enough space"
        message += ", only #{actual} bytes left" if actual
        message += ", but #{needed} needed" if needed
        super( message )
      end

    end

  end

end
