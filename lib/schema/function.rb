require 'ast/common/variable'
require 'ast/common/scoped_variable'
require 'schema/expression_type'
require 'errors/divide_by_zero_error'

module SquirrelDB

  module Schema

    class Function
      
      # +variable+:: The name of the function
      # +arg_types+:: An Array with the types of the arguments
      # +return_type+:: The return type
      # +&block+:: The code to be executed
      def initialize(variable, arg_types, return_type, &block)
        @variable = variable
        @arg_types = arg_types
        @proc = block
        @return_type = return_type
        @arg_types = arg_types
      end

      attr_reader :variable, :arg_types, :proc, :return_type
      
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
      
      # Shortcuts to make the notation more concise
      
      STRING = ExpressionType::STRING
      INTEGER = ExpressionType::INTEGER
      BOOLEAN = ExpressionType::BOOLEAN
      DOUBLE = ExpressionType::DOUBLE
      NULL_TYPE = ExpressionType::NULL_TYPE
      IDENTITY = lambda { |a| a }
      
      include AST
      
      public
      
      BUILT_IN = [
        Function.new(Variable.new("integer"), [STRING], INTEGER) { |s| s.nil? ? nil : s.to_i },
        Function.new(Variable.new("integer"), [DOUBLE], INTEGER) { |d| d.nil? ? nil : d.to_i },
        Function.new(Variable.new("integer"), [BOOLEAN], INTEGER) { |b| b.nil? ? nil : (b ? 1 : 0) },
        Function.new(Variable.new("integer"), [INTEGER], INTEGER, &IDENTITY),
        Function.new(Variable.new("integer"), [NULL_TYPE], INTEGER, &IDENTITY),
        Function.new(Variable.new("double"), [STRING], DOUBLE) { |s| s.nil? ? nil : s.to_f },
        Function.new(Variable.new("double"), [DOUBLE], DOUBLE, &IDENTITY),
        Function.new(Variable.new("double"), [BOOLEAN], DOUBLE) { |b| b.nil? ? nil : (b ? 1.0 : 0.0) },
        Function.new(Variable.new("double"), [INTEGER], DOUBLE) { |i| i.nil? ? nil : i.to_f },
        Function.new(Variable.new("double"), [NULL_TYPE], DOUBLE, &IDENTITY),
        Function.new(Variable.new("string"), [STRING], STRING, &IDENTITY),
        Function.new(Variable.new("string"), [DOUBLE], STRING) { |d| d.nil? ? nil : d.to_s },
        Function.new(Variable.new("string"), [BOOLEAN], STRING) { |b| b.nil? ? nil : (b ? "true" : "false") },
        Function.new(Variable.new("string"), [INTEGER], STRING) { |i| i.to_s },
        Function.new(Variable.new("string"), [NULL_TYPE], STRING, &IDENTITY),
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
      
    end

  end

end
