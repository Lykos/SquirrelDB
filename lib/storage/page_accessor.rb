require 'storage/constants'
require 'storage/exceptions/format_exception'

module RubyDB

  module Storage

    class PageAccessor

      include Constants

      def initialize( filename )
        @file = File.open( filename, File::RDWR )
      end

      def get( page_no )
        @file.seek(page_no * PAGE_SIZE, IO::SEEK_SET)
        page = @file.read( PAGE_SIZE )
        page = "\0" * PAGE_SIZE if page == nil
        page.ljust( PAGE_SIZE, "\0" )
      end

      def put( page_no, page )
        unless page.bytesize == PAGE_SIZE
          raise FormatException.new(
            "Only page size #{PAGE_SIZE} is allowed, actual size of new page number #{page_no} is #{page.bytesize}."
          )
        end
        @file.seek( page_no * PAGE_SIZE, IO::SEEK_SET )
        @file.write( page )
      end

      def close
        @file.close
      end

    end

  end
end
