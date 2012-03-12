require 'rel_alg/converter/converter'
require 'rel_alg/converter/rel_alg_converter'
require 'rel_alg/converter/verifier'
require 'rel_alg/converter/always_optimizer'

module RubyDB

  module RelAlg

    class ConverterManager

      def converter
        Converter.new( verifier, rel_alg_converter, always_optimizer )
      end

      def verifier
        Verifier.new
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
