require 'sql/elements/scoped_variable'

module RubyDB
  
  module Data

    class TableManager

      # TODO Place for this constants
      INTERNAL_SCOPE = "#internal#"
      SCHEMA_TABLE = "schema"

      def initialize( evaluator )
        @evaluator = evaluator
      end

      def get_page_no( table )
        if table.scope.name == INTERNAL_SCOPE
          case table.variable.name
          when SCHEMA_TABLE
          else
            raise "Unknown internal table #{table.variable.name}"
          end
        end
        scope_id = get_scope_id( table.scope )
        table_id = get_table_id( scope_id, table )
        internal_get_page_no( table_id )
      end

      private

      def get_scope_id( scope )
        if scope.kind_of?( SQL::ScopedVariable )
          get_scope_id( scope.scope )
          
        else
        end
      end
      
    end

  end
  
end
