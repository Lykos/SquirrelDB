require 'sql/preprocessor'
require 'sql/parser'

module SquirrelDB

  module SQL

    class ParserFactory

      def parser
        @parser ||= Parser.new(preprocessor)
      end

      def preprocessor
        @preprocessor ||= Preprocessor.new
      end
      
    end

  end
  
end
