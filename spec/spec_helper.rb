#encoding: UTF-8

gem 'rspec-encoding-matchers'
require 'rspec_encoding_matchers'

RSpec.configure do |config|
  config.color_enabled = true
  config.include RSpecEncodingMatchers
end
