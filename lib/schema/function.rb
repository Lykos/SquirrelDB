require 'ast/common/variable'
require 'ast/common/scoped_variable'
require 'schema/type'
require 'errors/divide_by_zero_error'

module SquirrelDB

  module Sql

    class Function

      def initialize(variable, arg_types, return_type, &proc)
        @variable = variable
        @arg_types = arg_types
        @proc = proc
        @return_type = return_type
        @arg_types = arg_types
      end

      attr_reader :proc, :return_type
      
      def ==(other)
        self.class == other.class &&
        @variable == other.variable &&
        @arg_types == other.arg_types
        @proc == other.proc &&
        @return_type == other.return_type
      end
      
      def eql?(other)
        self == other
      end
      
      def hash
        @hash ||= [@proc, @return_type].hash
      end
      
      protected
      
      STRING = ExpressionType::STRING
      INTEGER = ExpressionType::INTEGER
      BOOLEAN = ExpressionType::BOOLEAN
      DOUBLE = ExpressionType::DOUBLE
      NULL_TYPE = ExpressionType::NULL_TYPE
      IDENTITY = lambda { |a| a }
      
      public
      
      BUILTIN_FUNCTIONS = [
        Function.new(Variable("integer"), [STRING], INTEGER) { |s| s.nil? ? nil : s.to_i },
        Function.new(Variable("integer"), [DOUBLE], INTEGER) { |d| d.nil? ? nil : d.to_i },
        Function.new(Variable("integer"), [BOOLEAN], INTEGER) { |b| b.nil? ? nil : (b ? 1 : 0) },
        Function.new(Variable("integer"), [INTEGER], INTEGER, &IDENTITY),
        Function.new(Variable("integer"), [NULL_TYPE], INTEGER, &IDENTITY),
        Function.new(Variable("double"), [STRING], DOUBLE) { |s| s.nil? ? nil : s.to_f },
        Function.new(Variable("double"), [DOUBLE], DOUBLE, &IDENTITY),
        Function.new(Variable("double"), [BOOLEAN], DOUBLE) { |b| b.nil? ? nil : (b ? 1.0 : 0.0) },
        Function.new(Variable("double"), [INTEGER], DOUBLE) { |i| i.nil? ? nil : i.to_f },
        Function.new(Variable("double"), [NULL_TYPE], DOUBLE, &IDENTITY),
        Function.new(Variable("string"), [STRING], STRING, &IDENTITY),
        Function.new(Variable("string"), [DOUBLE], STRING) { |d| d.nil? ? nil : d.to_s },
        Function.new(Variable("string"), [BOOLEAN], STRING) { |b| b.nil? ? nil : (b ? "true" : "false") },
        Function.new(Variable("string"), [INTEGER], STRING) { |i| i.to_s },
        Function.new(Variable("string"), [NULL_TYPE], STRING, &IDENTITY),
        *[INTEGER, DOUBLE].map { |type| Function.new(Operator::UNARY_PLUS, [type], type, &IDENTITY) },
        *[INTEGER, DOUBLE].map { |type| Function.new(Operator::UNARY_MINUS, [type], type) { |a| a.nil? ? nil : -a } },
        *[INTEGER, DOUBLE].map { |type| Function.new(Operator::POWER, [type, type], type) { |a, b| a.nil? || b.nil? ? nil : a ** b } },
        *[INTEGER, DOUBLE].map { |type| Function.new(Operator::PLUS, [type, type], type) { |a, b| a.nil? || b.nil? ? nil : a + b } },
        *[INTEGER, DOUBLE].map { |type| Function.new(Operator::MINUS, [type, type], type) { |a, b| a.nil? || b.nil? ? nil : a - b } },
        *[INTEGER, DOUBLE].map { |type| Function.new(Operator::TIMES, [type, type], type) { |a, b| a.nil? || b.nil? ? nil : a * b } },
        Function.new(Operator::DIVIDED_BY, [INTEGER, INTEGER], INTEGER) do |a, b|
          a.nil? || b.nil? ? nil : (raise DivideByZeroError if b == 0; a / b)
        end,
        Function.new(Operator::DIVIDED_BY, [DOUBLE, DOUBLE], DOUBLE) { |a, b| a.nil? || b.nil? ? nil : a / b },
        Function.new(Operator::MODULO, [INTEGER, INTEGER], INTEGER) do |a, b|
          a.nil? || b.nil? ? nil : (raise DivideByZeroError if b == 0; a % b)
        end,
        Function.new(Operator::MODULO, [DOUBLE, DOUBLE], DOUBLE) { |a, b| a.nil? || b.nil? ? nil : a % b },
        Function.new(Operator::LEFT_SHIFT, [INTEGER, INTEGER], INTEGER) { |a, b| a.nil? || b.nil? ? nil : a << b },
        Function.new(Operator::RIGHT_SHIFT, [INTEGER, INTEGER], INTEGER) { |a, b| a.nil? || b.nil? ? nil : a >> b },
        Function.new(Operator::BIT_NOT, [INTEGER], INTEGER) { |a| a.nil? ? nil : ~a },
        Function.new(Operator::BIT_AND, [INTEGER, INTEGER], INTEGER) { |a, b| a.nil? || b.nil? ? nil : a & b },
        Function.new(Operator::BIT_OR, [INTEGER, INTEGER], INTEGER) { |a, b| a.nil? || b.nil? ? nil : a | b },
        Function.new(Operator::BIT_XOR, [INTEGER, INTEGER], INTEGER) { |a, b| a.nil? || b.nil? ? nil : a ^ b },
        *[INTEGER, DOUBLE].map { |type| Function.new(Operator::GREATER, [type, type], BOOLEAN) { |a, b| a.nil? || b.nil? ? nil : a > b } },
        *[INTEGER, DOUBLE].map { |type| Function.new(Operator::GREATER_EQUAL, [type, type], BOOLEAN) { |a, b| a.nil? || b.nil? ? nil : a >= b } },
        *[INTEGER, DOUBLE].map { |type| Function.new(Operator::SMALLER, [type, type], BOOLEAN) { |a, b| a.nil? || b.nil? ? nil : a < b } },
        *[INTEGER, DOUBLE].map { |type| Function.new(Operator::SMALLER_EQUAL, [type, type], BOOLEAN) { |a, b| a.nil? || b.nil? ? nil : a <= b } },
        *[INTEGER, DOUBLE].map { |type| Function.new(Operator::EQUAL, [type, type], BOOLEAN) { |a, b| a.nil? || b.nil? ? nil : a == b } },
        *[INTEGER, DOUBLE].map { |type| Function.new(Operator::UNEQUAL, [type, type], BOOLEAN) { |a, b| a.nil? || b.nil? ? nil : a != b } },
        Function.new(Operator::NOT, [BOOLEAN], BOOLEAN) { |a| a.nil? ? nil : !a },
        Function.new(Operator::AND, [BOOLEAN, BOOLEAN], BOOLEAN) { |a, b| a == false || b == false ? false : (a.nil? || b.nil ? nil : true) },
        Function.new(Operator::OR, [BOOLEAN, BOOLEAN], BOOLEAN) { |a, b| a || b ? true : (a.nil? || b.nil ? nil : false) },
        Function.new(Operator::XOR, [BOOLEAN, BOOLEAN], BOOLEAN) { |a, b| a.nil? || b.nil? ? nil : a != b },
        Function.new(Operator::IMPLIES, [BOOLEAN, BOOLEAN], BOOLEAN) { |a, b| a == false ? true : (a.nil? || b.nil? ? nil : b) },
        Function.new(Operator::IS_IMPLIED, [BOOLEAN, BOOLEAN], BOOLEAN) { |a, b| b == false ? true : (a.nil? || b.nil? ? nil : a) },
        Function.new(Operator::EQUIVALENT, [BOOLEAN, BOOLEAN], BOOLEAN) { |a, b| a.nil? || b.nil? ? nil : a == b }
      ]
            
      # Calls choose_function and caches the results
      def self.function(variable, arg_types)
        @@functions[[variable, arg_types]] = choose_function(variable, arg_types)
      end
      
      protected
      
      @@functions = {}

      def self.choose_function(variable, arg_types)
        candidates = BUILTIN_FUNCTIONS.select { |f| f.variable == variable }
        return :no_candidate if candidates.empty?
        exact_match = candidates.find { |f| f.arg_types == arg_types }
        return exact_match if exact_match
        conversion_candidates = candidates.select do |f|
          arg_types.zip(f.arg_types).all? { |args| arg[0].auto_converts_to?(arg[1]) }
        end
        if conversion_candidates.empty?
          :none
        elsif conversion_candidates.length == 1
          f = conversion_candidates[0]
          conversions = arg_types.zip(f.arg_types).all? { |args| args[0].auto_conversion_to(args[1]) }
          Function.new(f.variable, arg_types, f.return_type) do |*args|
            converted_args = conversions.zip(args).collect { |arg| arg[0].call(arg[1]) }
            f.proc.call(*converted_args)
          end
        else
          :ambiguous
        end
      end
      
    end

  end

end
