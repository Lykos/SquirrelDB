require 'storage/raw_util'
require 'storage/constants'

module SquirrelDB
  
  module Storage

    # Represents a page of the database file
    class Page

      # Creates a new empty page
      def self.new_empty
        new_page = self.allocate
        new_page.init_empty
        new_page
      end

      attr_reader :page_no, :content

      include RawUtil
      include Constants

      # Read the page type from the content, if necessary, and return it.
      def type
        @type ||= IDS_TYPES[type_id]
      end
      
      # Read the page type id from the content, if necessary, and return it.
      def type_id
        @type_id ||= extract_int(@content[0...TYPE_SIZE])
      end
      
      # Initializes a new empty page.
      def init_empty
        @content = "\x00" * PAGE_SIZE
        @type = self.class.to_s.split("::")[-1].intern
        @type_id = TYPES_IDS[@type]
        raise StorageError.new(
          "Page type #{self.class} has no type id."
        ) unless @type_id
        @content[0...TYPE_SIZE] = encode_int(@type_id, TYPE_SIZE)
      end
      
      # Returns the length of the header of this page type
      def header_size
        TYPE_SIZE
      end
      
      protected

      def initialize(page_no, content)
        if content.bytesize != PAGE_SIZE
          raise StorageError.new(
            "Page #{page_no} gets a content with length #{content.bytesize} instead of #{PAGE_SIZE}."
          )
        end
        @page_no = page_no
        @content = content
        if type != self.class.to_s.split("::")[-1].intern
          raise StorageError.new(
            "Page #{page_no} is not a #{self.class.to_s.split("::")[-1]}, its type_id is #{type_id}, so it type is #{type.to_s}."
          )
        end
      end

    end

  end
  
end
