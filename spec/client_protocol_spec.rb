# encoding: UTF-8

require 'client/client_protocol'
require 'errors/encoding_error'
require 'errors/internal_connection_error'
require 'protocol_shared_examples'
require 'spec_helper'

include SquirrelDB
include Client
include Server::Protocol

describe ClientProtocol do
  
  include_examples "protocols", ClientProtocol
    
  before :each do
    @cp = ClientProtocol.new
    @version_string = @cp.pack_version(VERSION)
    @server_hello = @version_string + "[LuP\xF2\xC9T\x93\x10\a\x9By\v\xF7~5\x8D\xA8S\xE8\x19\v'+D\x15\x9B\x8Cu\xAA#~\x00\x00\x00\x8D\x00\x00\x00@\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xC9\x0F\xDA\xA2!h\xC24\xC4\xC6b\x8B\x80\xDC\x1C\xD1)\x02N\b\x8Ag\xCCt\x02\v\xBE\xA6;\x13\x9B\"QJ\by\x8E4\x04\xDD\xEF\x95\x19\xB3\xCD:C\x9D\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x00\x00\x00\x01\x05\x00\x00\x00@$\x95i\xEF1=\x18\r~c\xDD\x8CHQ\xAE=\xFAD\xECI\x0F\x85\x01\x82S*`\xE4,\x9D\xB6\x84\xCB\xDE\xD0\x90q<\x86\xA9AGO%U-D\xB0\xC0\xC7\x04\x02\xA5\x19+\xE0FGOu\xF8\xB3\xD8\x11\x00\x00\x00I\x00\x00\x00@\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xC9\x0F\xDA\xA2!h\xC24\xC4\xC6b\x8B\x80\xDC\x1C\xD1)\x02N\b\x8Ag\xCCt\x02\v\xBE\xA6;\x13\x9B\"QJ\by\x8E4\x04\xDD\xEF\x95\x19\xB3\xCD:C\x9D\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x00\x00\x00\x01\x05\x00\x00\x00\x05\x00\x00\x00\x01\x00X[\x03\xAF\xA1\xA9\x1F\xAE\xD7\xEF\x00\x04<\xDC\xC4\xE2\xCE\x8A\xBCb\xD3\xBA0C\xB1H\xD6f\x06\xB5\xFC\x86\x944(\x8Ax\xF1\xF0\x87]\xF5z\xE3\x05(\xD8\\\x05lF+\xCE\xC3q\x90\x0Eg\xD5\xEC\xDAs\xE9\xE2\xD6\x11l\x94\x14\x96\x8D\xB7vb\xAC\xA9\x14\xB3\x93\x9C\xF7\xB86\x89\xBD\x87\xA7\xAC\f\xEE=?mz\xAE\xB1N \xB1\\\fO!>\x04\xC1Y\xB8\b?\xA6n\x96\xFD{\xDA}\xF4_\xA8\x05f\xA7Pf\nq\xC4".force_encoding(Encoding::BINARY)
  end

  it "should generate a client hello of the right length" do
    @cp.client_hello.length.should eq(VERSION_BYTES + NONCE_BYTES)
  end
  
  it "should generate a client hello that encodes the right version." do
    @cp.client_hello.should start_with(@version_string)
  end
  
  it "should generate a client hello with ASCII 8 Bit encoding" do
    @cp.client_hello.should be_binary_encoded
  end
  
  it "should return false after reading a server hello which is too short to contain the version" do
    @cp.read_server_hello("a".force_encoding(Encoding::BINARY)).should be_false
  end
  
  it "should raise an error in case of a server hello with an Encoding different from ASCII 8 Bit" do
    lambda { @cp.read_server_hello("a".force_encoding(Encoding::UTF_8)) }.should raise_error(SquirrelDB::EncodingError)
  end
  
  it "should raise an error after reading a server hello of an incompatible versions" do
    invalid_version = "\x00\x00".force_encoding(Encoding::BINARY)
    lambda { @cp.read_server_hello(invalid_version) }.should raise_error(ConnectionError)
  end
  
  it "should return false after reading a server hello which is too short to contain the n server nonce" do
    @cp.read_server_hello(@version_string + "asfd".force_encoding(Encoding::BINARY)).should be_false
  end
  
  it "should return false after reading an incomplete server hello" do
    10.times do |i|
      @cp.read_server_hello(@server_hello[0...@server_hello.length * i / 10]).should be_false
    end
  end
  
  it "should return true after reading a complete server hello" do
    @cp.read_server_hello(@server_hello).should be_true
  end
  
  it "should raise an error if the server hello is read twice" do
    @cp.read_server_hello(@server_hello)
    lambda { @cp.read_server_hello(@server_hello) }.should raise_error(InternalConnectionError)
  end
  
  it "should raise an error if the Diffie Hellman part is generated before the server hello has been read" do
    lambda { @cp.client_dh_part }.should raise_error(InternalConnectionError)
  end
  
end