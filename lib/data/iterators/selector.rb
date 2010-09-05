require 'data/iterators/iterator'

module Data

  class Selector < Iterator

    def initialize( expression, inner, evaluator )
      @expression = expression
      @inner = inner
      @evaluator = evaluator
    end

    def open
      @inner.open
    end

    def next_item
      while (t = @inner.next_item)
        return t if @evaluator.evaluate( @expression, TupleState.new( t ) )
      end
      nil
    end

    def close
      @inner.close
    end

    def rewind
      @inner.rewind
    end

  end

end
