module Mince
  require_relative 'model/fields'
  require_relative 'model/persistence'
  require_relative 'model/finders'
  require_relative 'model/data_model'

  # = Model
  #
  # The mince model is a module that provides standard model to data behavior to the Mince data model mixing for a specific model.
  #
  # Simply mixin this module in order to get a wrapper class to interact with a mince
  # interface for a specific collection
  #
  # Example:
  #   require 'mince'
  #
  #   class BookDataModel
  #     include Mince::DataModel
  #
  #     data_collection :books
  #     data_fields :title, :publisher
  #   end
  #
  #   class Book
  #     include Mince::Model
  #
  #     data_model BookDataModel
  #     fields :title, :publisher
  #   end
  #
  #   book = Book.new title: 'The World In Photographs', publisher: 'National Geographic'
  #   book.save
  #
  # By including this module, you are including DataModel, Fields, Persistence, and Finders.
  #
  # However, you can choose which modules you would like by including those modules individually 
  # so that you can have flexibility an lighter weight help to implement your models.
  #
  #   class AvailableBook
  #     include Mince::Model::DataModel
  #
  #     data_collection :books
  #
  #     def self.all
  #       data_collection.all_by_fields(library: "St. Louis - Downtown", available: true).map{ |a| new(a) }
  #     end
  #   end
  #
  module Model
    extend ActiveSupport::Concern

    included do
      include DataModel
      include Fields
      include Persistence
      include Finders
    end
  end
end
