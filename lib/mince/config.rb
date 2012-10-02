module Mince
  require 'singleton'

  class Config
    include Singleton

    attr_accessor :interface

    def self.interface=(interface)
      instance.interface = interface
    end

    def self.interface
      instance.interface
    end
  end
end
