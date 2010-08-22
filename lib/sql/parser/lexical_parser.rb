require 'syntax'

module Sql

  class LexicalParser

    include Syntax

    def initialize(string)
      @tokens = string.scan(TOKEN)
    end

    attr_reader :tokens
    
  end
  
end
