require 'rel_alg/converter'
require 'rel_alg/rel_alg_converter'
require 'rel_alg/verifier'
require 'rel_alg/always_optimizer'
require 'rel_alg/table_linker'

module SquirrelDB

  module RelAlg

    class ConverterManager

      def converter
        Converter.new( verifier, table_linker, rel_alg_converter, always_optimizer )
      end

      def verifier
        Verifier.new
      end
      
      def table_linker
        TableLinker.new
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
