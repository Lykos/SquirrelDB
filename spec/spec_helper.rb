#encoding: UTF-8

gem 'rspec-encoding-matchers'
require 'rspec_encoding_matchers'
require 'schema/expression_type'
require 'ast/sql/select_statement'
require 'ast/sql/select_clause'

module SquirrelDB
  
  module CustomMatchers
    
    class CalculateExpression
      
      include AST
      
      def initialize(expected)
        @expected = expected
      end
      
      def matches?(target)
        @target = target
        unless @target.is_a?(SelectStatement)
          @reason = "it is not even a select statement"
          return false
        end
        select_clause = @target.select_clause
        unless select_clause.is_a?(SelectClause)
          @reason = "its select clause is not even a proper select clause"
          return false
        end
        columns = select_clause.columns
        if columns.empty?
          @reason = "it has no columns"
          return false
        end
        if columns.length > 1
          @reason = "it has more than one column"
          return false
        end
        columns[0] == @expected
      end
      
      def failure_message
        "expected #{@target.inspect} to calculate expression #{@expected}" + (@reason ? " but " + @reason : "")
      end
      
      def negative_failure_message
        "expected #{@target.inspect} not to calculate expression #{@expected}"
      end
      
    end
  
    def calculate_expression(expected)
      CalculateExpression.new(expected)
    end
  
    class HaveType
      
      include Schema
      
      def initialize(type_sym)
        @type = ExpressionType.const_get(type_sym.upcase)
      end
      
      def matches?(target)
        @target = target
        target.type == @type
      end
      
      def failure_message
        "expected type #{@type}, but got type #{@target.type}."
      end
      
      def negative_failure_message
        "expected not type #{@type}, but got type #{@target.type}."
      end
      
    end
    
    def have_type(type_sym)
      HaveType.new(type_sym)
    end
  
  end
 
end

RSpec.configure do |config|
  config.color_enabled = true
  config.include RSpecEncodingMatchers
  config.include SquirrelDB::CustomMatchers
end
