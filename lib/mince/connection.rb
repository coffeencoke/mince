require 'mongo'
require 'singleton'
require 'active_support/core_ext/object/blank'

module Mince
  class Connection
    include Singleton

    attr_reader :connection, :db

    def initialize
      @connection = Mongo::Connection.new
      @db = connection.db(database)
    end

    # todo: push this into a config class which uses yaml or something like that to pull in the different environment settings?
    def database
      env_suffix = if (ENV['TEST_ENV_NUMBER'].blank?)
        ""
      else
        "-#{ENV['TEST_ENV_NUMBER']}"
      end
      "mince#{env_suffix}"
    end
  end
end