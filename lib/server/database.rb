require 'data/table_manager'
require 'data/internal_evaluator'
require 'schema/schema_manager'
require 'data/compiler/compiler_manager'
require 'sql/parser/parser_manager'
require 'rel_alg/converter_manager'

module SquirrelDB
  
  module Server
    
    class Database
  
      def initialize
        @table_manager = Data::TableManager.new
        @schema_manager = Schema::SchemaManager.new
        @schema_manager.table_manager = @table_manager
        @parser = SQL::ParserManager.new.parser
        @converter = RelAlg::ConverterManager.new.converter(@table_manager, @schema_manager)
        @compiler = Data::CompilerManager.new.compiler
        @internal_evaluator = InternalEvaluator.new(@compiler)
        @table_manager.internal_evaluator = @internal_evaluator
        @schema_manager.internal_evaluator = @internal_evaluator
      end
      
      def execute(query)
        @compiler.process(@converter.process(@parser.parse(query))).evaluate
      end
    
    end
    
  end
  
end