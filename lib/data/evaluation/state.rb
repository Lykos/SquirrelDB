module Sql

  class State

    def initialize
      @variables = {}
    end

    def []( name )
      @variable[name]
    end

    def []=( name, value )
      @variable[name] = value
    end

  end

end
