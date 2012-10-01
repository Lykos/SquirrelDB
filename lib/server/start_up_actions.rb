require 'server/option_merger'

module SquirrelDB

  module Server

    # TODO Better name
    class StartUpActions
      
      attr_reader :command_options, :defaults, :config
      
      # Outputs an error and exits if a file is present in the config, but does not exist and
      # is also not created by this script.
      # +file+:: The key to be used to look for the file. If this is nil, then nothing happens and the check is passed.
      # +create_option_key+:: The key to look up in the config if this script creates this file.
      # +create_option+:: The command line option which specifies that this script creates this file.
      # +file_error_name+:: How the file is called in the error message.
      def check_file_existence(file, create_option, file_error_name)
        if file && !file.exist?
          puts "Error: #{file_error_name} #{file} does not exist. Create it with #{create_option}."
          exit(false)
        end
      end

      # Outputs a warning if the main config file does not exist
      def warn_main_existence
        if !@command_options[:create_config] && !defaults.user_config_file.exist?
          warn "The main configuration file #{defaults.user_config_file} is not present."
          warn "Create a default one with --create-config."
        end
      end

      # Creates a new config file, if necessary.
      def create_config
        config_file = config[:config_file]
        if config[:create_config]
          puts "Created default config file at #{config_file}."
          write_file(
            config[:config_file],
            YAML::dump(config.select { |k, v| @defaults.default_options.has_key?(k) && k != :config_file }),
            'config'
          )
        end
      end
      
      def write_file(file, content, content_name, overwrite=config[:force])
        create_parent(file)
        check_writable(file, content_name + ' file', overwrite) 
        begin
          file.parent.mkpath
          File.open(file, 'w') do |f|
            f.write(content)
          end
        rescue Exception => e
          puts "Error while writing #{content_error_name} to file #{file}: #{e}"
          puts "The content of this file is now undefined."
          exit(false)
        end
      end
      
      def check_extension(file, extension, file_error_name)
        if file.extname != extension
          puts "Error: The #{file_error_name} #{file} does not have the required extension #{extension}."
          exit(false)
        end
      end
      
      def create_parent(file)
        if !file.parent.exist?
          file.parent.parent.ascend do |p|
            if p.exist?
              if !p.writable?
                puts "Error: #{p} is the first existing parent directory of the #{file_error_name} #{f}, but it is not writable."
                exit(false)
              else
                break
              end
            end
          end
          begin
            file.parent.mkpath
          rescue Exception => e
            puts "Error: Could not create the parent directories of #{file}: #{e}"
            exit(false)
          end
        end
      end
      
      def check_writable(file, file_error_name, overwrite=@config[:force])
        return true unless file.exist?
        if !overwrite
          puts "Error: The #{file_error_name} #{file} exists in file system. Use -f to overwrite."
          exit(false)
        elsif !file.writable?
          puts "Error: The #{file_error_name} #{file} is not writable."
          exit(false)
        elsif file.directory?
          puts "Error: The #{file_error_name} #{file} exists in file system and is a directory."
          exit(false)
        end
      end
      
      def check_present(option_key, error_message)
        unless @config[option_key]
          puts "Error: #{error_message}"
          exit(false)
        end
      end
      
      protected
      
      def initialize(command_options, defaults)
        @command_options = command_options
        @defaults = defaults
        @config = OptionMerger.new.options(defaults.default_options, defaults.config_files, command_options)
      end
      
    end
  
  end
  
end