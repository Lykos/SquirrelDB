require 'storage/raw_util'
require 'storage/constants'

module RubyDB
  
  module Storage

    class Page

      def initialize( page_no, content )
        if content.bytesize != PAGE_SIZE
          raise FormatException.new(
            "TuplePage #{page_no} gets a content with length #{content.bytesize} instead of #{PAGE_SIZE}."
          )
        elsif type != TYPE_IDS[self.class.to_s.split("::")[-1].intern]
          raise FormatException.new(
            "Page #{page_no} is not a #{self.class}, its type is #{type} instead of #{TYPE_IDS[self.class.to_s.intern]}."
          )
        end
        @content = content
        @page_no = page_no
      end

      attr_reader :page_no, :content

      include RawUtil
      include Constants

      private

      def type
        @type ||= extract_int( content[0...TYPE_SIZE] )
      end

    end

  end
  
end
