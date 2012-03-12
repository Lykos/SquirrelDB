require 'data/iterators/iterator'

module Data

  class Selector < Iterator

    def initialize( expression, inner, evaluator )
      super()
      @expression = expression
      @inner = inner
      @evaluator = evaluator
    end

    def_delegators :@inner, :open, :close, :rewind

    def next_item
      while (t = @inner.next_item)
        return t if @expression.evaluate( TupleState.new( @state, t ) )
      end
      nil
    end

  end

end
