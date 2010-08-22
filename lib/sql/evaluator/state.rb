module Sql

  class State

    def initialize
      @variables = {}
    end

    def get_variable(name)
      @variable[name]
    end

    def set_variable(name, value)
      @variable[name] = value
    end

  end

end
