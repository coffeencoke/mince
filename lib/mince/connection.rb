require 'mongo'
require 'singleton'
require_relative 'config'

module Mince
  class Connection
    include Singleton

    attr_reader :connection, :db

    def initialize
      @connection = Mongo::Connection.new
      @db = connection.db(Mince::Config.database_name)
    end
  end
end
