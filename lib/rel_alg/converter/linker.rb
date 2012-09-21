require 'rel_alg/elements/projection'
require 'rel_alg/elements/selection'
require 'sql/elements/operator'
require 'sql/elements/constant'
require 'sql/elements/variable'
require 'sql/elements/visitor'

module RubyDB

  module RelAlg

    class Linker < SQL::Visitor
      
      include SQL
      include RelAlg
      
      LinkInfo = Struct.new(offset, schema)
      
      def initialize( table_manager, schema_manager )
        @table_manager = table_manager
        @schema_manager = schema_manager
      end

      def process( statement )
        statement.visit( self )
        @variable_stack = []
      end

      def visit_from_clause( tables )
        variable_frame = @variable_stack.last.dup
        offset = 0
        FromClause.new(
          tables.collect do |t|
            if t.kind_of?(Variable) || t.kind_of?(ScopedVariable)
              schema = @schema_manager.get( offset, t )
              offset += schema.length
              # TODO Nested scopes, exception if name overwrite in same variable frame
              variable_frame[t.name] = LinkInfo.new(offset, schema)
              LinkedTable.new( schema, @table_manager.get_page_no(t) )
            elsif t.kind_of?(Renaming) && t.expression.kind_of?(Variable) || t.expression.kind_of?(ScopedVariable)
              schema = @schema_manager.get( offset, t.expression )
              offset += schema.length
              variable_frame[t.name] = LinkInfo.new(offset, schema)
              LinkedTable.new( schema, @table_manager.get_page_no(t.expression) )
            else
              t
            end
          end
        )
        @variable_stack.push(variable_frame)
      end
  
      def visit_variable(name)
        # TODO unscoped variables
        if @variable_stack.last.has_key?(name)
          @variable_stack[name]
        else
          Variable.new(name)
        end
      end
      
      def visit_scoped_variable(scope, name)
        if scope.kind_of?(LinkInfo)
          LinkedColumn.new(scope.schema.get_type(name), name, scope.schema.get_index(name))
        else
          ScopedVariable.new(scope, name)
        end
      end
      
      def visit_select_statement( select_clause, from_clause, where_clause )
        @variable_stack.pop
        super
      end
      
    end

  end

end
