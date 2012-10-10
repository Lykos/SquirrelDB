require 'compiler/iterator_compiler'
require 'compiler/compiler'
require 'compiler/linker'

module SquirrelDB
  
  module Data
    
    class CompilerFactory
      
      def compiler(tuple_wrapper, table_manager, schema_manager)
        @compiler ||= Compiler.new(iterator_compiler, linker(tuple_wrapper, table_manager, schema_manager))
      end
      
      def iterator_compiler
        @iterator_compiler ||= IteratorCompiler.new
      end
      
      def linker(tuple_wrapper, table_manager, schema_manager)
        @linker ||= Linker.new(tuple_wrapper, table_manager, schema_manager)
      end
      
    end
  
  end

end