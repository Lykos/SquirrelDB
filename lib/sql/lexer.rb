require 'errors/parse_error'
require 'errors/internal_error'
require 'ast/common/operator'
require 'strscan'

module SquirrelDB

  module SQL

    class Lexer

      include AST
      Rule = Struct.new(:pattern, :type)
      
      # Starts the parsing and sets the string to be parsed.
      def start(string)
        raise InternalError, "The lexer can only be used once." if @started
        @started = true
        @scanner = StringScanner.new(string)
      end
      
      def scan
        raise InternalError, "Scan can only be executed if the lexer is started." unless @started
        token = nil
        until token == [false, false]
          token = next_token
          yield token
        end
      end
      
      # Tokenizes the given string
      def process(string)
        start(string)
        tokens = []
        until tokens.last == [false, false]
          tokens << next_token
        end
        tokens
      end
      
      # Return the next token
      def next_token
        raise InternalError, "Scan can only be executed if the lexer is started." unless @started
        return [false, false] if @scanner.empty?
        token = extract_token
        token[0] == :SKIP ? next_token : token 
      end
      
      attr_reader :rules
      
      # Adds all the lexer rules for SQL.
      def add_sql_rules
        ignore(/\s+/)
        operators(*Operator::BINARY_OPERATORS)
        operators(*Operator::UNARY_OPERATORS)
        keywords(
          '.',
          ',',
          '*',
          'select',
          'from',
          'where',
          'insert',
          'into',
          'create',
          'table',
          'values',
          'update',
          'delete',
          'default',
          'set',
          'drop',
          'alter',
          'add',
          'column',
          'view',
          'scope',
          'null'
        )
        token(/\d+\.\d+/, :DOUBLE)
        token(/\d+/, :INTEGER)
        token(/true|false/i, :BOOLEAN)
        token(/(["'])(?:\\?.)*?\1/, :STRING)
        token(/[A-Za-z_]\w*/, :IDENTIFIER)
      end
      
      # Clears the rules, used for testing only.
      def clear_rules
        @rules.clear
      end
      
      # Adds a rule to ignore the following pattern
      def ignore(pattern)
        @rules << Rule.new(pattern, :SKIP)
      end
      
      # Adds a rule for a token
      def token(pattern, type)
        @rules << Rule.new(pattern, type)
      end
      
      # Adds a rule for an operator
      def operator(op)
        @rules << Rule.new(op.pattern, op.symbol)
      end
      
      # Adds rules for several operators
      def operators(*ops)
        ops.each { |op| operator(op) }
      end
      
      # Adds a rule for a case insensitive keyword
      def keyword(word)
        @rules << Rule.new(Regexp.new(Regexp.escape(word), Regexp::IGNORECASE), word)
      end
      
      # Adds rules for several case insensitive keywords
      def keywords(*words)
        words.each { |w| keyword(w) }
      end
      
      # Adds two rules for brackets
      def brackets(left, right)
        keyword(left)
        keyword(right)
      end
      
      protected
            
      # Initializes the rules as the SQL rules
      def initialize
        @rules = []
        add_sql_rules
      end
      
      private
      
      def extract_token
        @rules.each do |rule|
          m = @scanner.scan(rule.pattern)
          return [rule.type, m] if m
        end 
        raise SquirrelDB::ParseError, "Unexpected characters  <#{@scanner.peek(10)}>."
      end
      
    end
    
  end
  
end
