require 'sql/elements/scoped_variable'

module RubyDB
  
  module Data

    class TableManager

      # TODO Place for this constants
      INTERNAL_SCOPE = "#internal#"
      SCHEMA_TABLE = "schema"
      SCHEMA_TABLE_PAGE_ID = 0
      TOPLEVEL_SCOPE_ID = 1

      def initialize( evaluator, internal_evaluator )
        @evaluator = evaluator
        @internal_evaluator = internal_evaluator
      end

      def get_page_no( table )
        if table.scope.name == INTERNAL_SCOPE
          return get_internal_page_no( table )
        end
        scope_id = get_scope_id( table.scope )
        table_id = get_table_id( scope_id, table )
        internal_get_page_no( table_id )
      end

      private
      
      # get page_no for an internal page
      #
      def get_internal_page_no( table )
        case table.variable.name
        when SCHEMA_TABLE
          return SCHEMA_TABLE_PAGE_ID
        else
          raise "Unknown internal table #{table.variable.name}"
        end        
      end

      def get_scope_id( scope )
        if scope.kind_of?( SQL::ScopedVariable )
          parent_scope = get_scope_id( scope.scope )
        else
          parent_scope = TOPLEVEL_SCOPE
        end
        # TODO Remember what I wanted to do here... 
        @internal_evaluator.select( scope_id, scopes, 
      end
      
    end

  end
  
end
