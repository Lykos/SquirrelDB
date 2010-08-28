require 'storage/constants'

module RubyDB

  module Storage

    class PageAccessor

      include Constants

      def initialize( filename )
        @file = File.open( filename, File::RDWR )
      end

      def get( page_no )
        @file.seek(page_no * PAGE_SIZE, IO::SEEK_SET)
        @file.read( PAGE_SIZE )
      end

      def put( page_no, page )
        raise PageLengthException.new( page.length ) if page.length > PAGE_SIZE
        @file.seek( page_no * PAGE_SIZE, IO::SEEK_SET )
        @file.write( page.ljust( PAGE_SIZE, "\0" ) )
      end

      def close
        @file.close
      end

    end

  end
end
