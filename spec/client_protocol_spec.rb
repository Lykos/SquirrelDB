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
    @server_hello = "\x00\x03eruP-\x04\xE0s+\xFDYkM0.\x1C\x99qDW\x86\x8Fc5\xD7\xF9!V\xC7@u\xA9\x00\x00\x00\x8D\x00\x00\x00@\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xC9\x0F\xDA\xA2!h\xC24\xC4\xC6b\x8B\x80\xDC\x1C\xD1)\x02N\b\x8Ag\xCCt\x02\v\xBE\xA6;\x13\x9B\"QJ\by\x8E4\x04\xDD\xEF\x95\x19\xB3\xCD:C\x9D\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x00\x00\x00\x01\x05\x00\x00\x00@$\x95i\xEF1=\x18\r~c\xDD\x8CHQ\xAE=\xFAD\xECI\x0F\x85\x01\x82S*`\xE4,\x9D\xB6\x84\xCB\xDE\xD0\x90q<\x86\xA9AGO%U-D\xB0\xC0\xC7\x04\x02\xA5\x19+\xE0FGOu\xF8\xB3\xD8\x11\x00\x00\x00I\x00\x00\x00@\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xC9\x0F\xDA\xA2!h\xC24\xC4\xC6b\x8B\x80\xDC\x1C\xD1)\x02N\b\x8Ag\xCCt\x02\v\xBE\xA6;\x13\x9B\"QJ\by\x8E4\x04\xDD\xEF\x95\x19\xB3\xCD:C\x9D\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\x00\x00\x00\x01\x05\x00\x00\x00\x05\x00\x00\x00\x01\x00a\x10\xE0\x99\xBA\x05D\xBE\xD1F\xB5%\xB4\xF3\xD7K\x82\xCD\x81G\x02\x97\xF8=h&\b\xA6\xDDroC\xAC\xA6G\x7F\xB1\xF9\x91\x92J\xA7e\xE9\xD8\xFDN\x9CU)=\x95*U\xC8~\xEF\xF70\xBE@\xD4\x11\xE0\x91\xBEKQ\xF9I\e\xBC\x97=\a\xA8\x84\xA8\xFB\x91\x10\xEDo\x99\xFD\x1C\x920z\x18;\xF51\xB5K\a\xE3\xDCB\xC0\xB8\xB3\xAEPNG\eH8\xD9\xE1X\xE9\xE54e\x03c\x81[3{GT\xE0\xB1\xA70".force_encoding(Encoding::BINARY)
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