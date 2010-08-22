require 'table'

module Sql

  class Tables

    def initialize(*tables)
      @tables = *tables
    end

    attr_reader :tables

  end

end
