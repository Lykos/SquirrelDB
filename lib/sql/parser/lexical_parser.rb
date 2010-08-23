require 'syntax'
require 'pre_parser'

module Sql

  class LexicalParser

    def initialize( pre_parser=PreParser.new )
      @pre_parser = pre_parser
    end

    include Syntax

    def parse(string)
      @pre_parser.parse( string ).scan( TOKEN )
    end
    
  end
  
end
