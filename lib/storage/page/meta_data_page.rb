require 'storage/page/page'
require 'data/constants'

module SquirrelDB

  module Storage

    class MetaDataPage < Page
            
      TABLE_ID_SIZE = 8 # TODO Get this as the size of a short

      def variable_id
        extract_int(@content[header_size...header_size + TABLE_ID_SIZE])
      end
      
      def variable_id=(new_variable_id)
        @variable_id = new_variable_id
        @content[header_size...header_size + TABLE_ID_SIZE] = encode_int(@variable_id, TABLE_ID_SIZE)
      end
      
      def init_empty
        super
        self.variable_id = Data::Constants::INTERNAL_TABLE_IDS.values.max
      end

    end

  end

end
