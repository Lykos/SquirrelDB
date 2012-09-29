require 'data/table_manager'
require 'data/sequence_manager'
require 'data/data_initializer'
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
      
      FILE_EXTENSION = '.sqrl'
      
      def self.open(file, create_new=false)
        db = new(file, create_new)
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
      
      def closed?
        @closed
      end
      
      def close
        raise "Already closed" if @closed
        @closed = true
        @file.flock(File::LOCK_UN)
        @file.close
      end
      
      def compile(statement)
        @compiler.process(@converter.process(@parser.process(statement)))
      end
      
      def get_all(compiled_query)
        compiled_query.get_all(Data::State.new)
      end
      
      def execute(compiled_command)
        compiled_command.execute(Data::State.new)
      end
    
    private 
  
      def initialize(file, create_new=false)
        @closed = true
        raise "File #{file} does not have the #{FILE_EXTENSION} SquirrelDB extension." unless File.extname(file) == FILE_EXTENSION
        if create_new
          raise "File #{file} exists in file system." if File.exists?(file)
          @closed = false
          @file = File.new(file, "w+b")
          @file.flock(File::LOCK_EX)
          begin
            @storage_factory = Storage::StorageFactory.new(@file)
            @page_wrapper = @storage_factory.page_wrapper
            @data_initializer = Data::DataInitializer.new(@page_wrapper)
            @data_initializer.create
          rescue Exception
            close
            raise
          end
        else
          raise "Database file #{file} does not exist." unless File.exists?(file)
          @closed = false
          @file = File.new(file, "r+b")
          @file.flock(File::LOCK_EX)
        end
        begin
          @storage_factory ||= Storage::StorageFactory.new(@file)
          @page_wrapper ||= @storage_factory.page_wrapper
          @data_initializer ||= Data::DataInitializer.new(@page_wrapper)
          @table_manager = Data::TableManager.new
          @schema_manager = Schema::SchemaManager.new
          @sequence_manager = Data::SequenceManager.new(@page_wrapper)
          @schema_manager.table_manager = @table_manager
          @table_manager.sequence_manager = @sequence_manager
          @table_manager.data_initializer = @data_initializer
          @parser = SQL::ParserFactory.new.parser
          @converter = RelAlg::ConverterFactory.new.converter(@table_manager, @schema_manager)
          @tuple_wrapper = @storage_factory.tuple_wrapper
          @compiler = Data::CompilerFactory.new.compiler(@tuple_wrapper, @table_manager, @schema_manager)
          @internal_evaluator = Data::InternalEvaluator.new(@compiler)
          @table_manager.internal_evaluator = @internal_evaluator
          @schema_manager.internal_evaluator = @internal_evaluator
        rescue Exception
          close
          raise
        end
      end
    
    end
    
  end
  
end