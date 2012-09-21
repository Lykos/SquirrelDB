require 'sql/elements/operator'
require 'sql/elements/constant'
require 'sql/elements/variable'
require 'sql/elements/scoped_variable'
require 'sql/elements/binary_operation'
require 'rel_alg/elements/selection'
require 'rel_alg/elements/projection'

module RubyDB

  module Data

    # A convenience class for internal queries.
    #
    class InternalEvaluator

      include SQL
      include RelAlg
      
      def initialize( compiler )
        @compiler = compiler
      end

      def select( select_columns, from_table, where_columns, is_constants, is_types )
        # TODO Choose appropriate Exception
        raise RuntimeError unless where_columns.length > 0
        raise RuntimeError unless where_columns.length == is_constants.length && where_columns.length == is_types.length
        query = Projection.new(
          select_columns.map do |column|
            Variable.new( column )
          end,
          Selection.new(
            where_columns.zip(is_constants, is_types).map do |b|
              BinaryOperation.new(
                Operator::EQUAL,
                Variable.new( b[0] ),
                Constant.new( b[1], b[2] )
              )
            end.reduce do |a, b|
              BinaryOperation.new(
                Operator::AND,
                a,
                b
              )
            end,
            ScopedVariable.new(
              Variable.new( INTERNAL_SCOPE ),
              Variable.new( from_table )
            )
          )
        )
        @compiler.process( query ).evaluate
      end
      
    end

  end
  
end
