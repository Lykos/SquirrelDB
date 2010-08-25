require 'page_accessor'
require 'page'

module Storage

  class PageWrapper
    
    def initialize( page_accessor )
      @page_accessor = page_accessor
    end

    def get( page_no )
      Page.new( @page_accessor.get( page_no ) )
    end

    def put( page_no, page )
      @page_accessor.put( page_no, page.content )
    end

  end

end
