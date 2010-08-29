module RubyDB

  module Sql

    module Constant

      def initialize(value)
        @value = value
      end

      attr_reader :value

    end

  end

end
