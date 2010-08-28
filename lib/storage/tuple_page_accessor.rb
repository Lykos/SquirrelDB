require 'page_accessor'
require 'tuple_page'

module Storage

  class TuplePageAccessor
    
    def initialize( page_accessor )
      @page_accessor = page_accessor
    end

    def get( page_no )
      TuplePage.new( page_no, @page_accessor.get( page_no ) )
    end

    def put( page )
      @page_accessor.put( page.page_no, page.content )
    end

    def close
      @page_accessor.close
    end

  end

end
