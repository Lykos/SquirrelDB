require 'ast/common/operator'
require 'ast/common/constant'
require 'ast/common/variable'
require 'ast/common/scoped_variable'
require 'ast/common/binary_operation'
require 'ast/rel_alg_operators/projection'
require 'ast/rel_alg_operators/selection'
require 'data/table_manager'
require 'schema/schema_manager'

module SquirrelDB

  module Data

    # A convenience class for internal queries.
    #
    class InternalEvaluator

      include AST
      
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
            PreLinkedTable.new(
              Schema::SchemaManager::INTERNAL_SCHEMATA["schemata"],
              "schemata",
              TableManager::INTERNAL_TABLE_ID["schemata"]
            )
          )
        )
        @compiler.process( query ).evaluate( {} )
      end
      
    end

  end
  
end
