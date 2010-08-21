require 'syntax'

module Sql

  class ArithmeticParser

    include Syntax
    
    def initialize( tokens )
      @tokens = tokens
    end

    def parse_expression( start_value )
      after_value = start_value
      token = tokens[after_value]
      expression_stack = []
      operator_stack = []
      bin_op = false
      while token =~ ARITHMETIC_CONTINUE
        if !bin_op && token =~ INTEGER
          expression_stack.push( Integer.new( token.to_i ) )
          bin_op = true
        elsif !bin_op && token =~ IDENTIFIER
          if token[after_value + 1] =~ PARENTHESE_OPEN
            operator_stack.push( token )
            bin_op = true
          else
            expression_stack.push( Variable.new( token ) )
          end
        elsif !bin_op && token =~ MINUS
          operator_stack.push( '@-' )
        elsif !bin_op && token =~ PLUS
        elsif bin_op 
        elsif bin_op && token =~ KOMMA
          token = operator_stack.top
          
        end
        after_value += 1
        token = tokens[after_value]
      end
    end

  end
  
end
