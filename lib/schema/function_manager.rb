require 'schema/function'

module SquirrelDB

  module Schema

    class FunctionManager
      
      # +functions+:: All the existing functions
      def initialize(functions)
        @functions = functions
        @cached_functions = {}
      end
                  
      # Calls choose_function to choose the right function and caches the results.
      # * If no built-in function has the name +variable+, +:no_candidate+ is returned.
      # * If there exists a built-in function with name +variable+ and argument
      #   types that are equal to +arg_types+ (null types in +arg_types+ are ignored)
      #   this function is returned.
      # * If there are two or more such functions, +:ambiguous_fitting+ is returned.
      # * If there exists no such function, but there exists one, such that the
      #   +arg_types+ can all be converted to its argument types, this function
      #   is returned.
      # * If there exist two or more such functions, +:ambiguous_convertible+ is
      #   returned.
      # * If there is a function with the right name, but none with the right
      #   types, +:none+ is returned.
      def function(variable, arg_types)
        @cached_functions[[variable, arg_types]] = choose_function(variable, arg_types)
      end
      
      protected
            
      def choose_function(variable, arg_types)
        candidates = @functions.select { |f| f.variable == variable }
        return :no_candidate if candidates.empty?
        fitting_candidates = candidates.select do |f|
          arg_types.zip(f.arg_types).all? { |arg| arg[0] == arg[1] || arg[0].null? }
        end
        if fitting_candidates.length == 1
          return fitting_candidates[0]
        elsif fitting_candidates.length > 1
          return :ambiguous_fitting
        end
        convertible_candidates = candidates.select do |f|
          arg_types.zip(f.arg_types).all? { |arg| arg[0].auto_converts_to?(arg[1]) }
        end
        if convertible_candidates.empty?
          :none
        elsif convertible_candidates.length == 1
          f = convertible_candidates[0]
          conversions = arg_types.zip(f.arg_types).all? { |args| args[0].auto_conversion_to(args[1]) }
          Function.new(f.variable, arg_types, f.return_type) do |*args|
            converted_args = conversions.zip(args).collect { |arg| arg[0].call(arg[1]) }
            f.proc.call(*converted_args)
          end
        else
          :ambiguous_conversion
        end
      end
      
    end

  end

end
