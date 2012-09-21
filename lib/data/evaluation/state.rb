module Sql

  class State

    def initialize
      @variables = {}
      @scopes = {}
    end

    def []( name )
      @variables[name]
    end

    def []=( name, value )
      @variables[name] = value
    end

  end

end
