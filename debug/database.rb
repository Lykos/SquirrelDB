#!/usr/bin/ruby

$:.unshift('lib')
  
require 'server/database'

include SquirrelDB
include Server

database = Database.new

