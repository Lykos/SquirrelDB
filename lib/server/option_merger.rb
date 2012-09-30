require 'yaml'

module SquirrelDB
  
  module Server

    # A class responsible for merging options from the command line with options from files and
    # default options.
    class OptionMerger
      
      # Takes options and replaces missing options with specified default options or the options
      # read from a file. Default options are overriden by options from a file and options from
      # files are overriden by options from files that appear later in the file list and options
      # from files are overridden by the given options.
      # +default_options+:: The default options, which are used if an option appears neither in a config
      #                     file nor in an actual file.
      # +config_files+:: List of config file names which are read in the order they appear in the list
      #                  overriding options from earlier files. All options from files override the default options.
      # +options+:: A hash table containing the command line options, they override all other options.
      #             If the key +:config_file+ appears, it is used as an additional config file.
      def options(default_options, confg_files, options)
        opts = default_options.dup
        defaults.config_files.each do |f|
          if f.kind_of?(String)
            f = Pathname(f)
          end
          if !f.exist?
            # That 
          elsif !f.file?
            warn "Config file #{f} is not a file and hence ignored."
          elsif !f.readable?
            warn "Config file #{f} is not readable and hence ignored."
          else
            opts.merge!(YAML::load(File.read(f)))
          end
        end
        opts.merge!(options)
      end
            
    end
    
  end
  
end