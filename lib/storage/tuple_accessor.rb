require 'page_accessor'

module Storage

  class TupleAccessor

    def initialize( page_accessor )
      @page_accessor = page_accessor
    end

    def get( *tids )
      
    end

    private

    def get_page( page_no, *tuple_nos )
      results = []
      tids = []
      page = @page_accessor.get( page_no )
      tuple_nos.each do |tuple_no|
        if page.moved?( tuple_no )
          tids.push( page.get_tid( tuple_no ) )
        else
          results.push( page.get_tuple( tuple_no ) )
        end
      end
      [results, tids]
    end

    def put_page( page_no, tuple_nos, values )
      @page_accessor.get( page_no )
    end

  end

end
