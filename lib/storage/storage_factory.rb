require 'storage/page_accessor'
require 'storage/page_wrapper'
require 'storage/tuple_accessor'
require 'storage/tid_list_accessor'
require 'storage/tuple_wrapper'

module SquirrelDB

  module Storage

    class StorageFactory
      
      def initialize(file)
        @file = file
      end

      def page_accessor
        @page_accessor ||= PageAccessor.new( @file )
      end

      def page_wrapper
        @page_wrapper ||= PageWrapper.new( page_accessor )
      end

      def tuple_accessor
        @tuple_accessor ||= TupleAccessor.new( page_wrapper )
      end

      def tid_list_accessor
        @tid_list_accessor ||= TidListAccessor.new( page_wrapper )
      end

      def tuple_wrapper
        @tuple_wrapper ||= TupleWrapper.new( tuple_accessor )
      end

      def tid_wrapper
        @tid_wrapper ||= TidWrapper.new( tuple_accessor )
      end

    end

  end
  
end
