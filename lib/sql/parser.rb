require 'sql/ast_parser.tab'
require 'sql/lexer'

module SquirrelDB

  module SQL

    class Parser

      def initialize(preprocessor)
        @preprocessor = preprocessor
      end

      def process(string)
        ast_parser = ASTParser.new
        lexer = Lexer.new
        lexer.start(@preprocessor.process(string))
        ast_parser.lexer = lexer
        ast_parser.parse
      end
      
    end

  end

end
