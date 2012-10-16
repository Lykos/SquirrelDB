require 'ast/common/scoped_variable'
require 'ast/common/variable'
require 'data/constants'

module SquirrelDB
  
  module Data

    class SequenceManager

      include Constants
      
      # TODO Make this work for all kinds of sequences, not only this internal one
      def new_variable_id
        page = @page_wrapper.get(META_DATA_PAGE_NO)
        variable_id = (page.variable_id += 1)
        @page_wrapper.set(page)
        variable_id
      end
      
      protected

      def initialize(page_wrapper)
        @page_wrapper = page_wrapper
      end
            
    end

  end
  
end
