reqiuire 'sql/elements/operator'

module RubyDB

  module Data

    # A convenience class for internal queries.
    #
    class InternalEvaluator

      def initialize( compiler )
        @compiler = compiler
      end

      def select( select_column, from_table, where_column, is_constant, is_type )
        query = Projection.new(
          Renaming.new( Variable.new( select_column ), select_column ),
          Selection.new( BinaryOperation.new(
              Operator::PLUS,
              Variable.new( where_column ),
              Constant.new( is_constant, is_type )
            ),
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
