module Data

  class Tuple

    def initialize( values )
      @values = values
    end

    attr_reader :values

    def []( column )
      @values[column]
    end

    def []=( column, value )
      @values[column] = value
    end

  end

end
