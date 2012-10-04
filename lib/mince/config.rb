module Mince # :nodoc:
  require 'singleton'

  # = Configuration for Mince
  #
  # Mince can be configured to interact with different mince supported data interfaces.
  #
  # Simply run the following to specify the data interface to use
  #   Mince::Config.interface = Mince::MyDb::Interface
  #
  # This is a singleton object in order to prevent multiple instances of this object from
  # being used.
  class Config
    include Singleton

    attr_accessor :interface

    # Sets the singleton's interface attribute so that you can change your storage strategy
    # without changing all references to that class.
    #
    # @param [Class] interface the Mince Supported Interface class
    def self.interface=(interface)
      instance.interface = interface
    end

    # Returns the interface that is configured to be used. Use this method instead of hard coding 
    # which mince interface to use throughout your code so that you can change mince interfaces
    # as needed.
    def self.interface
      instance.interface
    end
  end
end
