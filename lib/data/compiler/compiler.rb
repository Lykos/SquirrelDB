module SquirrelDB

  module Data
      
    class Compiler
  
      def initialize(iterator_compiler, linker)
        @iterator_compiler = iterator_compiler
        @linker = linker
      end
  
      def process(statement)
        @linker.process(@iterator_compiler.process(statement))
      end
  
    end
  
  end

end
