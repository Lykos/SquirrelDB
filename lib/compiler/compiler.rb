module SquirrelDB

  module Compiler
      
    class Compiler
  
      def initialize(type_annotator, rel_alg_converter, linker)
        @type_annotator = type_annotator
        @rel_alg_converter = rel_alg_converter
        @linker = linker
      end
  
      def process(statement)
        @linker.process(@rel_alg_converter.process(@type_annotator.process(statement)))
      end
  
    end
  
  end

end
