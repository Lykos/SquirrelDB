require 'data/constants'
require 'storage/constants'

module SquirrelDB
  
  module Data
    
    class DataInitializer
      
      include Data::Constants
      include Storage::Constants

      def initialize(page_wrapper)
        @page_wrapper = page_wrapper
      end

      def create
        meta_data_page = @page_wrapper.add(:MetaDataPage)
        unless meta_data_page.page_no == META_DATA_PAGE_NO
          raise "Meta data page is the #{meta_data_page.page_no}th page instead of the #{META_DATA_PAGE_NO}th."
        end
        INTERNAL_TABLE_IDS.each do |name, table_id|
          page = @page_wrapper.add(:VarTuplePage)
          unless page.page_no == INTERNAL_PAGE_NOS[table_id]
            raise "Table page for #{name} is the #{page.page_no}th page instead of the #{INTERNAL_PAGE_NO[table_id]}th."
          end
        end
        nil
      end
      
      def add_table
        @page_wrapper.add(:VarTuplePage).page_no
      end
            
    end

  end
  
end
