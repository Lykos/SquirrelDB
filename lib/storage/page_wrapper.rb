require 'storage/page/tuple_page'

module RubyDB
  
  module Storage

    class PageWrapper
    
      def initialize( page_accessor, type )
        @page_accessor = page_accessor
        @type = type
      end

      attr_reader :type

      def get( page_no )
        @type.new( page_no, @page_accessor.get( page_no ) )
      end

      def put( page )
        @page_accessor.put( page.page_no, page.content )
      end

      def close
        @page_accessor.close
      end
      
    end

  end

end
