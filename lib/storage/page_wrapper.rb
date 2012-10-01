require 'storage/constants'
require 'storage/raw_util'
require 'storage/page/all'

module SquirrelDB
  
  module Storage

    class PageWrapper
    
      def initialize( page_accessor )
        @page_accessor = page_accessor
      end

      attr_reader :type

      include RawUtil

      def get(page_no)
        content = @page_accessor.get( page_no )
        type_id = extract_int(content[0...TYPE_SIZE])
        raise StorageError, "Invalid page type id #{type_id}." unless IDS_TYPES.has_key?(type_id)
        page_class = Storage.const_get(IDS_TYPES[type_id])
        page_class.new(page_no, @page_accessor.get(page_no))
      end

      def set(page)
        @page_accessor.set(page.page_no, page.content)
      end

      def add(type)
        page_class = Storage.const_get(type)
        new_page = page_class.new_empty
        page_no = @page_accessor.add(new_page.content)
        page_class.new(page_no, new_page.content)
      end
      
    end

  end

end
