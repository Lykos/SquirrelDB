require 'ast/iterators/all'
require 'ast/visitors/transform_visitor'
require 'data/evaluation/expression_evaluator'

module SquirrelDB

  module Data

    class IteratorCompiler < AST::TransformVisitor
      
      include AST

      def process( statement )
        statement.accept( self )
      end
      
      def visit_selection( expression, inner )
        Selector.new(
          ExpressionEvaluator.new(expression),
          inner
        )
      end
      
      def visit_renaming( expression, name )
        expression
      end
      
      def visit_projection( columns, inner )
        Projector.new( columns.collect { |c| ExpressionEvaluator.new(c) }, inner )
      end
    end

  end

end
