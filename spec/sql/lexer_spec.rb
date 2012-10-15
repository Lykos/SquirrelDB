require 'sql/lexer'
require 'errors/parse_error'
require 'errors/internal_error'
require 'ast/common/operator'

include SquirrelDB::SQL

describe Lexer do
  
  before :each do
    @lexer = Lexer.new
  end
  
  context "if the rules are cleared" do
    
    before :each do
      @lexer.clear_rules
    end
    
    it "should raise an error if unexpected characters occur" do
      lambda { @lexer.process("asdf") }.should raise_error(SquirrelDB::ParseError)
    end
    
    it "should raise an error if started twice" do
      @lexer.start("dd")
      lambda { @lexer.start("sadf") }.should raise_error(InternalError)
    end
    
    it "should raise an error if scan is called without start" do
      lambda { @lexer.scan { |token| } }.should raise_error(InternalError)
    end
    
    it "should yield the right tokens in scan" do
      @lexer.should_receive(:scan).and_yield(["a", "a"]).and_yield(["a", "a"]).and_yield([false, false])
      @lexer.keyword("a")
      @lexer.start("aa")
      @lexer.scan { |token| }
    end
    
    it "should raise an error if next_token is called without start" do
      lambda { @lexer.next_token }.should raise_error(InternalError)
    end
    
    it "should return the right tokens with next_token" do
      @lexer.keyword("a")
      @lexer.start("aa")
      @lexer.next_token.should eq(["a", "a"])
      @lexer.next_token.should eq(["a", "a"])
      @lexer.next_token.should eq([false, false])
    end
    
    it "should process an empty string correctly" do
      @lexer.process("").should eq([[false, false]])
    end
    
    it "should ignore ignored characters" do
      @lexer.ignore(/a/)
      @lexer.keyword("h")
      @lexer.process("aaah").should eq([["h", "h"], [false, false]])
    end
    
    it "should process an operator correctly" do
      @lexer.operator(Operator::PLUS)
      @lexer.process("+").should eq([["+", "+"], [false, false]])
    end
    
    it "should process an alias of an operator correctly" do
      @lexer.operator(Operator::AND)
      @lexer.process("aNd").should eq([["&&", "aNd"], [false, false]])
    end
    
    it "should differentiate between different operators" do
      @lexer.operator(Operator::PLUS)
      @lexer.operator(Operator::AND)
      @lexer.process("and+").should eq([["&&", "and"], ["+", "+"], [false, false]])
    end
    
    it "should differentiate between different operators if they are given at once" do
      @lexer.operators(Operator::PLUS, Operator::AND)
      @lexer.process("and+").should eq([["&&", "and"], ["+", "+"], [false, false]])
    end
    
    it "should process a keyword correctly" do
      @lexer.keyword("hi")
      @lexer.process("hi").should eq([["hi", "hi"], [false, false]])
    end
    
    it "should process a keyword with different case letters correctly" do
      @lexer.keyword("hi")
      @lexer.process("Hi").should eq([["hi", "Hi"], [false, false]])
    end
    
    it "should differentiate between different keywords" do
      @lexer.keyword("a")
      @lexer.keyword("h")
      @lexer.process("ah").should eq([["a", "a"], ["h", "h"], [false, false]])
    end
    
    it "should differentiate between different keywords if they are given at once" do
      @lexer.keywords("a", "h")
      @lexer.process("ah").should eq([["a", "a"], ["h", "h"], [false, false]])
    end
    
    it "should process tokens correctly" do
      @lexer.token(/[ab]/, :ABLETTER)
      @lexer.process("ba").should eq([[:ABLETTER, "b"], [:ABLETTER, "a"], [false, false]])
    end
    
    it "should differentiate between different tokens" do
      @lexer.token(/[ab]/, :ABLETTER)
      @lexer.token(/[cd]/, :CDLETTER)
      @lexer.process("ad").should eq([[:ABLETTER, "a"], [:CDLETTER, "d"], [false, false]])
    end
    
    it "should differentiate between tokens and keywords" do
      @lexer.keyword("a")
      @lexer.token(/[cd]/, :CDLETTER)
      @lexer.process("ad").should eq([["a", "a"], [:CDLETTER, "d"], [false, false]])
    end
    
  end
  
  it "should tokenize an select statement correctly" do
    @lexer.process("selEct * from a.b where 1 = 1").should eq([
      ["select", "selEct"],
      ["*", "*"],
      ["from", "from"],
      [:IDENTIFIER, "a"],
      [".", "."],
      [:IDENTIFIER, "b"],
      ["where", "where"],
      [:INTEGER, "1"],
      ["=", "="],
      [:INTEGER, "1"],
      [false, false]
    ])
  end
  
  it "should parse a null constant correctly" do
    @lexer.process("nUll").should eq([
      ["null", "nUll"],
      [false, false]
    ])
  end
  
  it "should parse a boolean constant correctly" do
    @lexer.process("fAlse").should eq([
      [:BOOLEAN, "fAlse"],
      [false, false]
    ])
  end
  
  it "should parse a double constant correctly" do
    @lexer.process("2.3").should eq([
      [:DOUBLE, "2.3"],
      [false, false]
    ])
  end
  
  it "should parse an integer constant correctly" do
    @lexer.process("23").should eq([
      [:INTEGER, "23"],
      [false, false]
    ])
  end
  
  it "should parse a \"\" String correctly" do
    @lexer.process("\"asd'f\"").should eq([
      [:STRING, "\"asd'f\""],
      [false, false]
    ])
  end
  
  it "should parse a '' String correctly" do
    @lexer.process("'asd\"f'").should eq([
      [:STRING, "'asd\"f'"],
      [false, false]
    ])
  end
  
  it "should parse a '' String with escaped ' correctly" do
    @lexer.process("'asd\\'f'").should eq([
      [:STRING, "'asd\\'f'"],
      [false, false]
    ])
  end
  
  it "should parse a \"\" String with escaped \" correctly" do
    @lexer.process("\"asd\\\"f\"").should eq([
      [:STRING, "\"asd\\\"f\""],
      [false, false]
    ])
  end
  
  it "should parse a '' String with escaped \\ correctly" do
    @lexer.process("'asd\\\\'f").should eq([
      [:STRING, "'asd\\\\'"],
      [:IDENTIFIER, "f"],
      [false, false]
    ])
  end
  
  it "should parse a \"\" String with escaped \\ correctly" do
    @lexer.process("\"asd\\\\\"f").should eq([
      [:STRING, "\"asd\\\\\""],
      [:IDENTIFIER, "f"],
      [false, false]
    ])
  end
  
  it "should tokenize an arithmetic expression correctly" do
    @lexer.process("a + b << -3 ** d.e").should eq([
      [:IDENTIFIER, "a"],
      ["+", "+"],
      [:IDENTIFIER, "b"],
      ["<<", "<<"],
      ["-", "-"],
      [:INTEGER, "3"],
      ["**", "**"],
      [:IDENTIFIER, "d"],
      [".", "."],
      [:IDENTIFIER, "e"],
      [false, false]
    ])
  end
  
  it "should tokenize an boolean expression correctly" do
    @lexer.process("a || b < 2 <-> d.e").should eq([
      [:IDENTIFIER, "a"],
      ["||", "||"],
      [:IDENTIFIER, "b"],
      ["<", "<"],
      [:INTEGER, "2"],
      ["<->", "<->"],
      [:IDENTIFIER, "d"],
      [".", "."],
      [:IDENTIFIER, "e"],
      [false, false]
    ])
  end
  
end
