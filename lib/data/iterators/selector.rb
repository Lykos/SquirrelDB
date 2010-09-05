require 'data/iterators/iterator'

module Data

  class Selector < Iterator

    def initialize( expression, inner, evaluator )
      @expression = expression
      @inner = inner
    end

    def open
      @inner.open
    end

    def next_item
      while (t = @inner.next_item)
      end
      nil
    end

    def close
      @inner.close
    end

  end

end
