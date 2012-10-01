require 'storage/constants'
require 'storage/exceptions/format_exception'

module SquirrelDB

  module Storage

    class PageAccessor

      include Constants

      def initialize( file )
        @file = file
        unless @file.size % PAGE_SIZE == 0
          raise StorageError.new(
            "The size of the file is not a multiple of #{PAGE_SIZE}"
          )
        end
      end

      def get(page_no)
        @file.seek(page_no * PAGE_SIZE, IO::SEEK_SET)
        page = @file.read( PAGE_SIZE )
        page = "\0" * PAGE_SIZE if page == nil
        page.ljust( PAGE_SIZE, "\0" )
      end

      def set(page_no, page)
        unless page.bytesize == PAGE_SIZE
          raise StorageError.new(
            "Only page size #{PAGE_SIZE} is allowed, actual size of new page number #{page_no} is #{page.bytesize}."
          )
        end
        @file.seek( page_no * PAGE_SIZE, IO::SEEK_SET )
        @file.write(page)
      end

      def add(page)
        unless @file.size % PAGE_SIZE == 0
          raise StorageError.new(
            "The size of the file is #{@file.size} instead of a multiple of #{PAGE_SIZE}"
          )
        end
        unless page.bytesize == PAGE_SIZE
          raise StorageError.new(
            "Only page size #{PAGE_SIZE} is allowed, actual size of new page number #{page_no} is #{page.bytesize}."
          )
        end
        @file.seek( @file.size, IO::SEEK_SET )
        page_no = @file.size / PAGE_SIZE
        @file.write(page)
        page_no
      end

    end

  end
end
