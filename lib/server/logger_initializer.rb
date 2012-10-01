gem 'logging'
require 'logging'

module SquirrelDB
  
  module Server
    
    # Class that is used to initalize the logger.
    class LoggerInitializer
      
      STDOUT_PATTERN = '%l %X{client}: %m\n'
      LOG_FILE_PATTERN = '[%d] %l %X{client}: %m\n'

      # Initializes a logger from the given config such that it outputs the log into stderr and a file.
      def init
        log = Logging.root.add_appenders(
          Logging.appenders.stdout(
            :backtrace => false,
            :level => @config[:verbose] ? :info : :warn,
            :layout => Logging.layouts.pattern(STDOUT_PATTERN)
          ),
          Logging.appenders.rolling_file(
            @log_file,
            :backtrace => true,
            :level => :debug,
            :layout => Logging.layouts.pattern(LOG_FILE_PATTERN)
          )
        )
      end

      protected
      
      # +log_file+:: The file the log is written into
      # +config+:: A hash table containing at least the key +:log_level+ and maybe +:verbose+.
      def initialize(log_file, config)
        @log_file = log_file
        @config = config
      end

    end
      
  end

end
