require 'expression'

module Sql

  class Variable < Expression

    def initialize( name )
      @name = name
    end

    attr_reader :name

  end

end
