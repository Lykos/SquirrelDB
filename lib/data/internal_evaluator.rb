require 'ast/common/operator'
require 'ast/common/constant'
require 'ast/common/variable'
require 'ast/common/scoped_variable'
require 'ast/common/binary_operation'
require 'ast/rel_alg_operators/projection'
require 'ast/rel_alg_operators/selection'
require 'data/constants'
require 'schema/constants'
require 'schema/schema'
require 'data/state'
require 'errors/data_error'

module SquirrelDB

  module Data

    # A convenience class for internal queries.
    #
    class InternalEvaluator

      include AST
      
      def initialize(compiler)
        @compiler = compiler
        @log = Logging.logger[self]
      end
      
      def insert(into_table, columns, values)
        raise DataError, "Columns and constants have different lengths." unless columns.length == values.length
        insert = Insert.new(
          internal_table(into_table),
          columns.collect { |c| Variable.new(c) },
          Values.new(values.collect { |v| Constant.new(v, ExpressionType::NULL_TYPE) }) # TODO null type is a temporary hack
        )
        @log.debug("Executing internal insert #{insert}.")
        @compiler.process(insert).execute(State.new)
      end
      
      def internal_table(table)
        ScopedVariable.new(Variable.new(Data::Constants::INTERNAL_SCOPE), Variable.new(table))
      end

      def select(select_columns, from_table, where_columns, is_constants)
        raise DataError, "No columns specified" unless where_columns.length > 0
        raise DataError, "Columns and constants have different lengths." unless where_columns.length == is_constants.length
        schema = Schema::Constants::INTERNAL_SCHEMATA[from_table]
        query = SelectStatement.new(
          SelectClause.new(select_columns.collect { |c| Variable.new(c) }),
          FromClause.new([internal_table(from_table)]),
          WhereClause.new(
            where_columns.zip(is_constants).map do |b|
              column_name, constant = b
              column = schema.column(column_name)
              BinaryOperation.new(
                Operator::EQUALS,
                Variable.new(column_name),
                Constant.new(constant, column.type.expression_type)
              )
            end.reduce { |a, b| BinaryOperation.new(Operator::AND, a, b) }
          )
        )
        @log.debug("Executing internal query #{query}.")
        answer = @compiler.process(query).query(State.new)
        @log.debug("Got answer #{answer} for internal query.")
        answer
      end
      
    end

  end
  
end
