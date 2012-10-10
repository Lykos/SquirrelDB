require 'ast/common/operator'
require 'ast/common/constant'
require 'ast/common/variable'
require 'ast/common/scoped_variable'
require 'ast/common/binary_operation'
require 'ast/rel_alg_operators/projection'
require 'ast/rel_alg_operators/selection'
require 'data/constants'
require 'schema/constants'
require 'schema/table_schema'
require 'data/state'

module SquirrelDB

  module Data

    # A convenience class for internal queries.
    #
    class InternalEvaluator

      include AST
      
      def initialize(compiler)
        @compiler = compiler
      end
      
      def insert(into_table, columns, values)
        raise "Columns and constants have different lengths." unless columns.length == values.length
        schema = Schema::Constants::INTERNAL_SCHEMATA[into_table]
        want_columns = columns.map do |col|
          c = schema.column(col)
        end
        have_columns = want_columns.map.with_index do |col, i|
          Column.new(col.name, col.type, i)
        end
        insert = Insert.new(
          PreLinkedTable.new(
            schema,
            into_table,
            TableManager::INTERNAL_TABLE_IDS[into_table]
          ),
          want_columns,
          DummyTable.new(Schema::TableSchema.new(have_columns), Tuple.new(values))
        )
        @compiler.process(insert).execute(State.new)
      end

      def select(select_columns, from_table, where_columns, is_constants)
        # TODO Choose appropriate Exception
        raise "No columns specified" unless where_columns.length > 0
        raise "Columns and constants have different lengths." unless where_columns.length == is_constants.length
        schema = Schema::Constants::INTERNAL_SCHEMATA[from_table]
        query = Projection.new(
          select_columns.map do |column_name|
            schema.column(column_name)
          end,
          Selection.new(
            where_columns.zip(is_constants).map do |b|
              column_name, constant = b
              column = schema.column(column_name)
              BinaryOperation.new(
                Operator::EQUAL,
                column,
                Constant.new(constant, column.type)
              )
            end.reduce do |a, b|
              BinaryOperation.new(
                Operator::AND,
                a,
                b
              )
            end,
            PreLinkedTable.new(
              schema,
              from_table,
              Constants::INTERNAL_TABLE_IDS[from_table]
            )
          )
        )
        @compiler.process(query).query(State.new)
      end
      
    end

  end
  
end
