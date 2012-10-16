#encoding UTF-8

require 'spec_helper'
require 'schema/storage_type'

include SquirrelDB::Schema

shared_examples "storage_types_values" do |type, value|
  
  it "should have an invertible load/store" do
    type.load(type.store(value)).should eq(value)
  end

  it "should make the stored string empty after loading" do
    s = type.store(value)
    type.load(s)
    s.should be_empty
  end
  
end

shared_examples "storage_types" do |type, value|
    
  context "if the type is #{type.name}" do
    
    context "for null" do
    
      include_examples "storage_types_values", type, nil
 
    end
        
    context "for a normal value" do
    
      include_examples "storage_types_values", type, value
  
    end
    
  end
    
end

describe StorageType do
  
  include_examples "storage_types", StorageType::STRING, "asdfasdfasfasdf".force_encoding(Encoding::UTF_8) 

  include_examples "storage_types", StorageType::BOOLEAN, false

  include_examples "storage_types", StorageType::INTEGER, 23234239872349877892398797824798

  include_examples "storage_types", StorageType::DOUBLE, 23.3    

  include_examples "storage_types", StorageType::SHORT, 23322    

end
