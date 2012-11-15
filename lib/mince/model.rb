module Mince
  require_relative 'model/fields'
  require_relative 'model/persistence'

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
  # View the docs for each method available
  module Model
    extend ActiveSupport::Concern

    included do
      include Fields
      include Persistence
    end
  end
end
