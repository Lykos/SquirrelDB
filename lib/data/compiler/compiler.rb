module RubyDB

  class Compiler

    def initialize( type_checker, access_checker, operator_compiler, linker )
      @type_checker = type_checker
      @access_checker = access_checker
      @operator_compiler = operator_compiler
      @linker = linker
    end

    def process( statement )
      @type_checker.process( statement )
      @access_checker.process( statement )
      @linker.process( @operator_compiler.process( statement ) )
    end

  end

end
