require 'sql/parser/pre_parser'
require 'sql/parser/lexical_parser'
require 'sql/parser/syntactic_parser'
require 'sql/parser/parser'

module RubyDB

  module Sql

    class ParserManager

      def parser
        Parser.new( pre_parser, lexical_parser, syntactic_parser )
      end

      def pre_parser
        @pre_parser ||= PreParser.new
      end

      def lexical_parser
        @lexical_parser ||= LexicalParser.new
      end

      def syntactic_parser
        SyntacticParser.new
      end
      
    end

  end
  
end
