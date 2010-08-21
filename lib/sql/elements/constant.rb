module Sql

  class Constant < Expression

    def initialize(value)
      @value = value
    end

    attr_reader :value

  end

end
