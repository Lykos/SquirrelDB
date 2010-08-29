require 'sql/elements/constant'
require 'sql/elements/boolean_expression'

module RubyDB

  module Sql

    class BooleanConstant < BooleanExpression

      include Constant

    end

  end

end
