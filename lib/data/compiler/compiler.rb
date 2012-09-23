module SquirrelDB

  module Data
      
    class Compiler
  
      def initialize( type_checker, iterator_compiler, linker )
        @type_checker = type_checker
        @iterator_compiler = iterator_compiler
        @linker = linker
      end
  
      def process( statement )
        @type_checker.process( statement )
        @linker.process( @iterator_compiler.process( statement ) )
      end
  
    end
  
  end

end
