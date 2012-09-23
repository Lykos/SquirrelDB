require 'data/compiler/iterator_compiler'
require 'data/compiler/type_checker'
require 'data/compiler/compiler'
require 'data/compiler/linker'

module SquirrelDB
  
  module Data
    
    class CompilerFactory
      
      def compiler(tuple_wrapper, table_manager)
        Compiler.new(type_checker, iterator_compiler, linker(tuple_wrapper, table_manager))
      end
      
      def type_checker
        TypeChecker.new
      end
      
      def iterator_compiler
        IteratorCompiler.new
      end
      
      def linker(tuple_wrapper, table_manager)
        Linker.new(tuple_wrapper, table_manager)
      end
      
    end
  
  end

end