module RubyDB

  class Compiler

    def initialize( type_checker, iterator_compiler )
      @type_checker = type_checker
      @iterator_compiler = iterator_compiler
      @linker = linker
    end

    def process( statement )
      @type_checker.process( statement )
      @iterator_compiler.process( statement )
    end

  end

end
