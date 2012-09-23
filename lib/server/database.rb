require 'data/table_manager'
require 'data/internal_evaluator'
require 'schema/schema_manager'
require 'data/compiler/compiler_factory'
require 'sql/parser_factory'
require 'rel_alg/converter_factory'
require 'data/evaluation/state'
require 'storage/storage_factory'

module SquirrelDB
  
  module Server
    
    class Database
      
      DATA_FILE = 'try/data.sqrl'
      
      def self.open
        db = new
        if block_given?
          begin
            yield db
          ensure
            db.close unless db.closed?
          end
        else
          db
        end
      end
  
      def initialize
        @closed = false
        @file = File.new(DATA_FILE, "r+b")
        @file.flock(File::LOCK_EX)
        @table_manager = Data::TableManager.new
        @schema_manager = Schema::SchemaManager.new
        @schema_manager.table_manager = @table_manager
        @parser = SQL::ParserFactory.new.parser
        @converter = RelAlg::ConverterFactory.new.converter(@table_manager, @schema_manager)
        @tuple_wrapper = Storage::StorageFactory.new.tuple_wrapper(@file)
        @compiler = Data::CompilerFactory.new.compiler(@tuple_wrapper, @table_manager)
        @internal_evaluator = Data::InternalEvaluator.new(@compiler)
        @table_manager.internal_evaluator = @internal_evaluator
        @schema_manager.internal_evaluator = @internal_evaluator
      end
      
      def closed?
        @closed
      end
      
      def close
        @closed = true
        @file.flock(File::LOCK_UN)
        @file.close
      end
      
      def compile(query)
        @compiler.process(@converter.process(@parser.process(query)))
      end
      
      def evaluate(compiled_query)
        compiled_query.evaluate(Data::State.new)
      end
    
    end
    
  end
  
end