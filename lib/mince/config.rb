require 'active_support/core_ext/object/blank'
require 'singleton'

module Mince
  class Config
    include Singleton

    attr_reader :database_name

    def initialize
      self.database_name = "mince"
    end

    def database_name=(val)
      @database_name = [val, ENV['TEST_ENV_NUMBER']].compact.join("-")
    end

    def self.database_name
      instance.database_name
    end

    def self.database_name=(val)
      instance.database_name = val
    end
  end
end
