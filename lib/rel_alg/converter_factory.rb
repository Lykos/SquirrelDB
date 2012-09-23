require 'rel_alg/converter'
require 'rel_alg/rel_alg_converter'
require 'rel_alg/verifier'
require 'rel_alg/always_optimizer'
require 'rel_alg/pre_linker'

module SquirrelDB

  module RelAlg

    class ConverterFactory

      def converter(table_manager, schema_manager)
        Converter.new( verifier, pre_linker(table_manager, schema_manager), rel_alg_converter, always_optimizer )
      end

      def verifier
        Verifier.new
      end
      
      def pre_linker(table_manager, schema_manager)
        PreLinker.new(table_manager, schema_manager)
      end

      def rel_alg_converter
        RelAlgConverter.new
      end

      def always_optimizer
        AlwaysOptimizer.new
      end
      
    end

  end

end
