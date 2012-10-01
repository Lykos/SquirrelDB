require 'ast/iterators/all'
require 'ast/visitors/transform_visitor'

module SquirrelDB

  module Data

    class IteratorCompiler
      
      include AST
      include TransformVisitor

      def process(statement)
        visit(statement)
      end
      
      def visit_selection(selection)
        Selector.new(
          ExpressionEvaluator.new(visit(selection.expression)),
          visit(selection.inner)
        )
      end
      
      def visit_projection(projection)
        Projector.new(
          projection.columns.collect { |c| ExpressionEvaluator.new(visit(c)) },
          visit(projection.inner)
        )
      end
      
    end

  end

end
