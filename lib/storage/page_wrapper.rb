require 'storage/constants'
require 'storage/raw_util'

module RubyDB
  
  module Storage

    class PageWrapper
    
      def initialize( page_accessor )
        @page_accessor = page_accessor
      end

      attr_reader :type

      include RawUtil

      def get( page_no )
        content = @page_accessor.get( page_no )
        type_id = extract_int( content[0...TYPE_SIZE] ) # TODO
        type = Storage.const_get( TYPE_IDS[type_id] )
        type.new( page_no, @page_accessor.get( page_no ) )
      end

      def set( page )
        @page_accessor.set( page.page_no, page.content )
      end

      def add_tuple_page( type_id )
        type = Storage.const_get( TYPE_IDS[type_id] )
        new_page = type.new_empty
        page_no = @page_accessor.add( new_page )
        type.new( page_no, new_page.content )
      end

      def close
        @page_accessor.close
      end
      
    end

  end

end
