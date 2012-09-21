require 'data/compiler/iterator_compiler'
require 'data/compiler/type_checker'
require 'data/compiler/compiler'

module SquirrelDB
  
  class CompilerManager
    
    def compiler
      Compiler.new(type_checker, iterator_compiler)
    end
    
    def type_checker
      TypeChecker.new
    end
    
    def iterator_compiler
      IteratorCompiler.new
    end
    
  end

end