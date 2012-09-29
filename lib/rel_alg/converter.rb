module SquirrelDB

  module RelAlg

    class Converter

      def initialize(pre_linker, rel_alg_converter)
        @pre_linker = pre_linker
        @rel_alg_converter = rel_alg_converter
      end

      def process(statement)
        @rel_alg_converter.process(@pre_linker.process(statement))
      end
      
    end

  end
  
end
