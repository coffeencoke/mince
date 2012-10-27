require 'active_support'
require 'active_model'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/object/instance_variables'

module Mince
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
      include ActiveModel::Conversion
      extend ActiveModel::Naming

      attr_accessor :id
    end

    module ClassMethods
      # Sets or returns the data model class for the model
      def data_model(model=nil)
        @data_model = model if model
        @data_model
      end

      # Returns all models from the data model
      def all
        data_model.all.map{|a| new a }
      end

      # Returns a model that matches a given id, returns nil if none found
      def find(id)
        a = data_model.find(id)
        new a if a
      end

      # Adds a field to the object.  Takes options to indicate assignability.  If `assignable`
      # is set, the field will be assignable via 
      #   model.field = 'foo'
      #   model.attributes = { field: 'foo' }
      #
      def field(field_name, options={})
        if options[:assignable]
          add_assignable_field(field_name)
        else
          add_readonly_field(field_name)
        end
      end

      # Adds a read only field, values for these fields can only be set in the class itself
      # or from the hash sent in to the initializer
      def add_readonly_field(field_name)
        fields << field_name
        readonly_fields << field_name
        attr_reader field_name
      end

      # Adds an assignable field, values for these fields can be set using the field writer
      # or from the `attributes=` method.
      def add_assignable_field(field_name)
        fields << field_name
        assignable_fields << field_name
        attr_accessor field_name
      end

      # Adds multiple readonly fields to the fields array, and returns the current list
      # of fields.  If no fields are given, it just returns the current list of fields
      def fields(*field_names)
        @fields ||= []
        field_names.each {|field_name| field(field_name) }
        @fields
      end

      # Returns the list of assignable fields
      def assignable_fields
        @assignable_fields ||= []
      end

      # Returns the list of readonly fields
      def readonly_fields
        @readonly_fields ||= []
      end
    end

    delegate :data_model, :assignable_fields, :readonly_fields, :fields, to: 'self.class'

    # Sets values (for fields defined by calling .field or .fields) in the hash to the object 
    # includes assignable and non-assignable fields
    def initialize(hash={})
      @id = hash[:id]
      readonly_fields.each do |field_name|
        self.instance_variable_set("@#{field_name}", hash[field_name]) if hash[field_name]
      end
      self.attributes = hash
    end

    # Returns true if the record indicates that it has been persisted to a data model.
    # Returns false otherwise.
    def persisted?
      !!id
    end

    # Saves the object to the data model.  Stores if new, updates previous entry if it has already
    # been saved.
    def save
      ensure_no_extra_fields
      if persisted?
        data_model.update(self)
      else
        @id = data_model.store(self)
      end
    end

    # Sets values (for assignable fields only, defined by calling .field or .fields) in the hash
    # to the object.
    #
    # Allows the proxy to have whitelisted attributes to be assigned from http requests.
    def attributes=(hash={})
      assignable_fields.each do |field|
        send("#{field}=", hash[field]) if hash[field]
      end
    end

    private

    # Ensures that the data model has all of the fields that are trying to be saved. Raises an
    # exception if the data model does not.
    def ensure_no_extra_fields
      extra_fields = (fields - data_model.data_fields)
      if extra_fields.any?
        raise "Tried to save a #{self.class.name} with fields not specified in #{data_model.name}: #{extra_fields.join(', ')}"
      end
    end
  end
end
