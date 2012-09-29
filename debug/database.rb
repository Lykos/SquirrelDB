#!/usr/bin/ruby

$:.unshift('lib')
  
require 'server/database'

include SquirrelDB
include Server

File.delete('try/data.sqrl')
Database.open('try/data.sqrl', true) do |db|
  compiled_create = db.execute(db.compile("create table a (name string, id short)"))
  db.execute(db.compile("insert into a (name) values (\"blu\")"))
  db.execute(db.compile("insert into a (name, id) values (\"bla\", 2)"))
  compiled_select = db.compile("select a.name, id from a")
  p db.get_all(compiled_select)
end
Database.open('try/data.sqrl') do |db|
  compiled_create = db.execute(db.compile("create table b (num short)"))
  db.execute(db.compile("insert into b (num) select 2"))
  db.execute(db.compile("insert into a (name, id) values (\"suss\", 5)"))
  compiled_select = db.compile("select a.name, id from a")
  p db.get_all(compiled_select)
  compiled_select = db.compile("select * from b")
  p db.get_all(compiled_select)
end
puts "Finished"
