require 'data/table_manager'
require 'data/sequence_manager'
require 'data/data_initializer'
require 'data/internal_evaluator'
require 'schema/function_manager'
require 'schema/function'
require 'schema/schema_manager'
require 'compiler/compiler_factory'
require 'sql/parser_factory'
require 'data/state'
require 'storage/storage_factory'

module SquirrelDB
  
  module Server
    
    # Facade class that creates all the objects needed for the database and manages the communication.
    class Database
      
      def self.open(file, config)
        db = new(file, config)
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
        parsed = @parser.process(statement)
        @log.debug("Parsed #{parsed.inspect}.")
        statement = @database_mutex.synchronize { @compiler.process(@parser.process(statement)) }
        @log.debug "Compiled #{statement}."
        statement
      end
      
      def query(compiled_query)
        response = @database_mutex.synchronize { compiled_query.query(Data::State.new) }
        @log.debug "Query executed."
        response
      end
      
      def execute(compiled_command)
        response = @database_mutex.synchronize { compiled_command.execute(Data::State.new) }
        @log.debug "Statement executed."
        response
      end
    
    private 
  
      # +file+:: Pathname to the database file
      # +config+:: Hash table which may contain the key +:force+ or +:create_database+
      def initialize(file, config)
        @log = Logging.logger[self]
        @closed = true
        if config[:create_database]
          @log.debug "Creating database for file #{file}."
          raise "File #{file} exists in file system." if file.exist? && !config[:force]
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
          raise "Database file #{file} does not exist." unless file.exist?
          @closed = false
          @file = File.new(file, "r+b")
          @file.flock(File::LOCK_EX)
        end
        begin
          @log.debug "Creating objects."
          @storage_factory ||= Storage::StorageFactory.new(@file)
          @page_wrapper ||= @storage_factory.page_wrapper
          @data_initializer ||= Data::DataInitializer.new(@page_wrapper)
          @table_manager = Data::TableManager.new
          @schema_manager = Schema::SchemaManager.new
          @function_manager = Schema::FunctionManager.new(Function::BUILT_IN)
          @sequence_manager = Data::SequenceManager.new(@page_wrapper)
          @schema_manager.table_manager = @table_manager
          @table_manager.sequence_manager = @sequence_manager
          @table_manager.data_initializer = @data_initializer
          @parser = SQL::ParserFactory.new.parser
          @tuple_wrapper = @storage_factory.tuple_wrapper
          @compiler = Compiler::CompilerFactory.new(@tuple_wrapper, @schema_manager, @function_manager, @table_manager).compiler
          @internal_evaluator = Data::InternalEvaluator.new(@compiler)
          @table_manager.internal_evaluator = @internal_evaluator
          @schema_manager.internal_evaluator = @internal_evaluator
          @database_mutex = Mutex.new
          @log.debug "Initialized all objects."
        rescue Exception => e
          close
          raise e
        end
      end
    
    end
    
  end
  
end