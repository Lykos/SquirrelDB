require 'rel_alg/stateful_pre_linker'

module SquirrelDB

  module RelAlg

    class PreLinker

      def initialize(table_manager, schema_manager)
        @table_manager = table_manager
        @schema_manager = schema_manager
      end

      def process(statement)
        StatefulPreLinker.new(@table_manager, @schema_manager).process(statement)
      end
      
    end

  end
  
end
