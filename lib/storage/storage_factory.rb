require 'storage/page_accessor'
require 'storage/page_wrapper'
require 'storage/tuple_accessor'
require 'storage/tid_list_accessor'
require 'storage/tuple_wrapper'

module SquirrelDB

  module Storage

    class StorageFactory

      def page_accessor(file)
        @page_accessor ||= PageAccessor.new( file )
      end

      def page_wrapper(file)
        @page_wrapper ||= PageWrapper.new( page_accessor(file) )
      end

      def tuple_accessor(file)
        @tuple_accessor ||= TupleAccessor.new( page_wrapper(file) )
      end

      def tid_list_accessor(file)
        @tid_list_accessor ||= TidListAccessor.new( page_wrapper(file) )
      end

      def tuple_wrapper(file)
        @tuple_wrapper ||= TupleWrapper.new( tuple_accessor(file) )
      end

      def tid_wrapper(file)
        @tid_wrapper ||= TidWrapper.new( tuple_accessor(file) )
      end

    end

  end
  
end
