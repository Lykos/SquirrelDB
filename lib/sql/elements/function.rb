require 'expression'

module Sql

  class Function < Expression

    def initialize( name, parameters )
      @name = name
      @parameters = parameters
    end

    attr_reader :name, :parameters

  end
  
end
