require 'ast/rel_alg_operators/all'
require 'ast/visitors/transform_visitor'

module SquirrelDB

  module RelAlg

    class RelAlgConverter
      
      include AST
      include TransformVisitor

      def process(statement)
        visit(statement)
      end

      def visit_select_statement(select_statement)
        selection = Selection.new(
          visit(select_statement.where_clause),
          visit(select_statement.from_clause)
        )
        select_columns = visit(select_statement.select_clause)
        # TODO General wild card handling
        if select_columns.length == 1 && select_columns[0].kind_of?(WildCard)
          selection
        else
          Projection.new(
            select_columns,
            selection
          )
        end
      end
      
      def visit_select_clause(select_clause)
        select_clause.columns.collect { |column| visit(column) } 
      end
      
      def visit_from_clause(from_clause)
        if from_clause.tables.empty?
          DummyTable.new(Schema::TableSchema.new([Column.new("x", Schema::Type::SHORT, 0)]), Tuple.new([0])) # TODO Refactor dummytable
        else
          from_clause.tables.reduce { |a, b| Cartesian.new(a, b) }
        end
      end
      
      def visit_where_clause(where_clause)
        where_clause.expression
      end
      
      def visit_tuple(tuple)
        DummyTable.new(tuple.dup)
      end

    end

  end

end
