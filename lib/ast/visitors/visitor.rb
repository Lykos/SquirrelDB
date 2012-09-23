module SquirrelDB

  module AST
    
    class Visitor
      
      def visit_select_statement( select_clause, from_clause, where_clause )
        nil
      end

      def visit_select_clause( columns )
        nil
      end

      def visit_from_clause( tables )
        nil
      end
      
      def visit_where_clause( expression )
        nil
      end

      def visit_from_clause( columns, tables, expression )
        nil
      end
      
      def visit_wild_card( wild_card )
        nil
      end

      def visit_renaming( renaming, variable )
        nil
      end

      def visit_binary_operation( operator, left, right )
        nil
      end

      def visit_unary_operation( unary_operation )
        nil
      end

      def visit_function_application( function_application )
        nil
      end

      def visit_constant( value, type )
        nil
      end

      def visit_scoped_variable( scope, variable )
        nil
      end

      def visit_variable( name )
        nil
      end

      def visit_renaming( expression, name )
        nil
      end
      
      def visit_selector( expression, inner )
        nil
      end
      
      def visit_projector( renamings, inner )
        nil
      end
      
      def method_missing(name, *args)
        if name.to_s =~ /^visit_/
          raise RuntimeError, "Unknown visitor operation #{name}."
        else
          super
        end
      end
      
    end

  end
  
end