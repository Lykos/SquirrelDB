require 'ast/sql/from_clause'
require 'ast/common/scoped_variable'
require 'ast/common/variable'
require 'ast/common/linked_column'
require 'ast/common/pre_linked_table'
require 'ast/common/renaming'
require 'ast/visitors/transform_visitor'

module SquirrelDB

  module RelAlg

    class PreLinker < AST::TransformVisitor
      
      include AST
      
      LinkInfo = Struct.new(:offset, :schema)
      
      def initialize( table_manager, schema_manager )
        @table_manager = table_manager
        @schema_manager = schema_manager
      end

      def process( statement )
        @variable_stack = []
        ast = statement.accept( self )
        p ast
        raise unless @variable_stack.empty?
        ast
      end

      def visit_from_clause( tables )
        variable_frame = @variable_stack.empty? ? {} : @variable_stack.last.dup
        offset = 0
        from = FromClause.new(
          tables.collect do |t|
            if t.kind_of?(Variable) || t.kind_of?(ScopedVariable)
              schema = @schema_manager.get( t )
              offset += schema.length
              # TODO Nested scopes, exception if name overwrite in same variable frame
              variable_frame[t.name] = LinkInfo.new(offset, schema)
              PreLinkedTable.new( schema, t.name, @table_manager.get_variable_id(t) )
            elsif t.kind_of?(Renaming) && t.expression.kind_of?(Variable) || t.expression.kind_of?(ScopedVariable)
              schema = @schema_manager.get( t.expression )
              offset += schema.length
              variable_frame[t.name] = LinkInfo.new(offset, schema)
              PreLinkedTable.new( schema, t.name, @table_manager.get_variable_id(t.expression) )
            else
              t
            end
          end
        )
        @variable_stack.push(variable_frame)
        from
      end
  
      def visit_variable(name)
        # TODO unscoped variables
        if !@variable_stack.empty? && @variable_stack.last.has_key?(name)
          @variable_stack.last[name]
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
        statement = super
        @variable_stack.pop
        statement
      end
      
    end

  end

end
