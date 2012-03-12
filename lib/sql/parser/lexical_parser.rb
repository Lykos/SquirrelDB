require 'sql/parser/syntax'
require 'sql/parser/pre_parser'

module RubyDB

  module Sql

    class LexicalParser

      include Syntax

      def process( string )
        string.scan( TOKEN )
      end

    end
    
  end
  
end
