#!/usr/bin/ruby

$:.unshift('lib')
  
gem 'logging'
require 'logging'
require 'server/database'
require 'pathname'

include SquirrelDB
include Server

Logging.logger.root.level = :debug
Logging.logger.root.add_appenders(
  Logging.appenders.stdout(
    :backtrace => true,
    :level => :debug
  )
)

file = Pathname.new('try/data.sqrl')
file.delete if file.exist?
Database.open(file, {:force => true, :create_database => true}) do |db|
  compiled_create = db.execute(db.compile("create table a (name string, id short)"))
  db.execute(db.compile("insert into a (name) values (\"blu\")"))
  db.execute(db.compile("insert into a (name, id) values (\"bla\", 2)"))
  compiled_select = db.compile("select a.name, id from a")
  p db.get_all(compiled_select)
end
Database.open(file, {}) do |db|
  compiled_create = db.execute(db.compile("create table b (num short)"))
  db.execute(db.compile("insert into b (num) select 2"))
  db.execute(db.compile("insert into a (name, id) values (\"suss\", 5)"))
  compiled_select = db.compile("select a.name, id from a")
  p db.query(compiled_select)
  compiled_select = db.compile("select * from b")
  p db.query(compiled_select)
end
puts "Finished"
