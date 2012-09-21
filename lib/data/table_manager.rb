require 'ast/scoped_variable'
require 'ast/variable'

module SquirrelDB
  
  module Data

    class TableManager

      # TODO Find a better place for these constants
      INTERNAL_SCOPE = "#internal#"
      TOPLEVEL_SCOPE_ID = 1
      INTERNAL_TABLE_ID = {
        "schemata" => 1,
        "variables" => 2,
        "tables" => 3
      }
      
      INTERNAL_PAGE_NO = {
        "schemata" => 1,
        "variables" => 2,
        "tables" => 3
      }

      attr_accessor :internal_evaluator

      def get_page_no( table )
        if table.kind_of?(SQL::ScopedVariable) && table.scope.kind_of?(SQL::Variable) && table.scope.name == INTERNAL_SCOPE
          return INTERNAL_PAGE_NO[table.variable.name]
        end
        table_id = get_object_id( table )
        # TODO Create constants for names in appropriate locations
        no = @internal_evaluator.select(
               ["page_no"],
               "tables",
               ["table_id"],
               [table_id],
               [SHORT]
             )
        # TODO Appropriate exception
        raise RuntimeError if no.length != 1
        no[0][0]
      end

      private
      
      # get page_no for an internal page
      #
      def get_internal_page_no( table_name )
        if INTERNAL_PAGE_NO.has_key?( table_name )
          INTERNAL_PAGE_NO[table_name]
        else
          # TODO Choose appropriate exception
          raise RuntimeError, "Unknown internal table #{table.variable.name}"
        end        
      end

      def get_variable_id( variable )
        if scope.kind_of?( SQL::ScopedVariable )
          scope_id = get_scope_id( scope.scope )
        else
          scope_id = TOPLEVEL_SCOPE_ID
        end
        # TODO Create constants for names in appropriate locations
        id = @internal_evaluator.select(
          ["variable_id"],
          "variables",
          ["scope_id", "variable_name"],
          [parent_scope_id, variable.name],
          [SHORT, STRING]
        )
        # TODO Appropriate exception
        raise RuntimeError if id.length != 1
        id[0][0]
      end
      
    end

  end
  
end
