require 'expression'

module Sql

  class FunctionApplication < Expression

    def initialize( function, parameters )
      @function = function
      @parameters = parameters
    end

    attr_reader :function, :parameters

  end
  
end
