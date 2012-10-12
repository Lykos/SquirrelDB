require 'compiler/rel_alg_converter'
require 'compiler/compiler'
require 'compiler/linker'
require 'compiler/type_annotator'

module SquirrelDB
  
  module Compiler
    
    class CompilerFactory
      
      def initialize(tuple_wrapper, schema_manager, table_manager)
        @tuple_wrapper = tuple_wrapper
        @schema_manager = schema_manager
        @table_manager = table_manager
      end
      
      def type_annotator
        @type_annotator ||= TypeAnnotator.new(@schema_manager, @table_manager)
      end
      
      def compiler
        @compiler ||= Compiler.new(type_annotator, rel_alg_converter, linker)
      end
      
      def linker
        @linker ||= Linker.new(@tuple_wrapper, @schema_manager, @table_manager)
      end
      
      def rel_alg_converter
        @rel_alg_converter ||= RelAlgConverter.new
      end
      
    end
  
  end

end