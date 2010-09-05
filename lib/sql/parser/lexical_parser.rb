require 'sql/parser/syntax'
require 'sql/parser/pre_parser'

module RubyDB

  module Sql

    class LexicalParser

      def initialize( pre_parser=PreParser.new )
        @pre_parser = pre_parser
      end

      include Syntax

      def process(string)
        @pre_parser.process( string ).scan( TOKEN )
      end

    end
    
  end
  
end
