require 'storage/raw_util'
require 'storage/constants'

module SquirrelDB
  
  module Storage

    class Page

      def initialize( page_no, content )
        if content.bytesize != PAGE_SIZE
          raise FormatException.new(
            "TuplePage #{page_no} gets a content with length #{content.bytesize} instead of #{PAGE_SIZE}."
          )
        elsif TYPE_IDS[type] != self.class.to_s.split("::")[-1].intern
          raise FormatException.new(
            "Page #{page_no} is not a #{self.class}, its type is #{TYPE_IDS[type]} instead of #{TYPE_IDS[self.class.to_s.intern]}."
          )
        end
        @content = content
        @page_no = page_no
      end

      def self.new_empty
        new_page = self.allocate
        new_page.init_empty
        new_page
      end

      attr_reader :page_no, :content

      include RawUtil
      include Constants

      def type
        @type ||= extract_int( content[0...TYPE_SIZE] )
      end

      private

      def init_empty
        @content = "\x00" * PAGE_SIZE
        @type = TYPE_IDS[type]
        @content[0...TYPE_SIZE] = encode_int( type, TYPE_SIZE )
      end
      
    end

  end
  
end
