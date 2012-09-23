require 'storage/constants'
require 'storage/exceptions/format_exception'

module SquirrelDB

  module Storage

    class PageAccessor

      include Constants

      def initialize( file )
        @file = file
        unless @file.size % PAGE_SIZE == 0
          raise FormatException.new(
            "The size of the file is not a multiple of #{PAGE_SIZE}"
          )
        end
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

      def add( page )
        size = File.size( @file.name )
        unless size % PAGE_SIZE == 0
          raise FormatException.new(
            "The size of the file is not a multiple of #{PAGE_SIZE}"
          )
        end
        @file.seek( size, IO::SEEK_SET )
        @file.write( page )
        size / PAGE_SIZE
      end

    end

  end
end
