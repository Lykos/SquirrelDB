#!/usr/bin/ruby

$:.unshift('lib')
  
require 'server/database'

include SquirrelDB
include Server

Database.open do |db|
  puts db.compile("select a.b from a") 
end

