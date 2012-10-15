require 'sql/preprocessor'

include SquirrelDB::SQL

describe Preprocessor do
  
  before :each do
    @prep = Preprocessor.new
  end
  
  it "should leave a lines without comment unchanged" do
    @prep.process("asdf\ndd").should match(/asdf\s+dd/m)
  end
  
  it "should remove a line comment correctly" do
    @prep.process("asdf --ddd\nfff").should match(/asdf \s+fff/m)
  end
  
end