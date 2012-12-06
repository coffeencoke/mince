require 'active_support/hash_with_indifferent_access'
require 'active_support/core_ext/object/instance_variables'
require 'active_support/core_ext/hash/slice'
require 'active_support/concern'

require_relative 'config'

module Mince # :nodoc:
  # = DataModel
  #
  # Mince::DataModel is used as a mixin to easily mixin behavior into an object that 
  # you wish to act as a data model and interact with mince data interfaces.
  #
  # Simply mixin this module in order to get a wrapper class to interact with a mince
  # interface for a specific collection
  #
  # Example:
  #   require 'mince/data_model'
  #
  #   class UserDataModel
  #     include Mince::DataModel
  #
  #     data_collection :users
  #     data_fields :username, :first_name, :last_name, :email, :password
  #   end
  #
  # To access methods on the data model do the following:
  #   user = User.new first_name: 'Matt'  # initialize a user from some User class
  #   user.id = UserDataModel.store user  # returns the id of the stored user
  #
  #   UserDataModel.find 1                # => returns the data for the user with an id of 1
  #   UserDataModel.find_all              # => returns all users
  #
  # View the docs for each method available
  module DataModel
    extend ActiveSupport::Concern

    included do
      # creates readonly attribute for id and model
      attr_reader :id, :model
    end

    module ClassMethods # :nodoc:
      # The interface configured by Mince::Config.interface=
      #
      # @returns [Class] interface class to be used by all mince data interactions
      def interface
        Config.interface
      end

      # Sets what data fields to accept
      # Returns the fields
      #
      # * Calling multiple times will do an ammendment to the existing list of fields
      # * Calling without any fields will simply return the current list of fields
      #
      # @param [*Array] *fields an array of fields to add to the data model
      # @returns [Array] the fields defined for the data model
      def data_fields(*fields)
        create_data_fields(*fields) if fields.any?
        @data_fields
      end

      # Sets the name of the data collection
      # Returns the name of the data collection
      #
      # @param [String] collection_name the name of the collection to use
      # @returns [String] returns the name of the collection
      def data_collection(collection_name = nil)
        set_data_collection(collection_name) if collection_name
        @data_collection
      end

      # Stores the given model into the data store
      #
      # @param [Class] model a ruby class instance object to store into the data store
      # @returns [id] returns the id of the newly stored object
      def store(model)
        new(model).tap do |p|
          p.add_to_interface
        end.id
      end

      # Updates the given model in the data store with the fields and values in model
      #
      # Uses model.id to find the record to update
      #
      # @param [Class] model a ruby class instance object to store into the data store
      def update(model)
        new(model).tap do |p|
          p.replace_in_interface
        end
      end

      # Updates a specific field with a value for the record with the given id
      #
      # @param [id] id the id of the record to update
      # @param [Symbol] field the field to update
      # @param [*] value the value to update the field with
      def update_field_with_value(id, field, value)
        interface.update_field_with_value(data_collection, id, field, value)
      end

      # Increments a field by a given amount
      #
      # Some databases provide very efficient algorithms for incrementing or decrementing a 
      # value.
      #
      # @param [id] id the id of the record to update
      # @param [Symbol] field the field to update
      # @param [Numeric] amount the amount to increment or decrement the field with
      def increment_field_by_amount(id, field, amount)
        interface.increment_field_by_amount(data_collection, id, field, amount)
      end

      # Removes a value from an field that is an array
      #
      # @param [id] id the id of the record to update
      # @param [Symbol] field the field to update
      # @param [*] value the value to update the field with
      def remove_from_array(id, field, value)
        interface.remove_from_array(data_collection, interface.primary_key, id, field, value)
      end

      # Pushes a value to an array field
      #
      # @param [id] id the id of the record to update
      # @param [Symbol] field the field to update
      # @param [*] value the value to update the field with
      def push_to_array(id, field, value)
        interface.push_to_array(data_collection, interface.primary_key, id, field, value)
      end

      # Returns a record that has the given id
      #
      # Returns nil if nothing found
      #
      # @param [id] id the id of the record to find
      # @returns [HashWithIndifferentAccess, nil] a hash with the data for the record
      def find(id)
        translate_from_interface interface.find(data_collection, interface.primary_key, id)
      end

      # Deletes a field from all records in the collection
      #
      # @param [Symbol] field the field to remove
      def delete_field(field)
        interface.delete_field(data_collection, field)
      end


      # Deletes a field from all records that matches the field / value key pairs in the 
      # params provided in the collection
      #
      # This will only delete records that match all key/value pairs in the params hash.
      #
      #   DataModel.delete_by_params(username: 'railsgrammer', first_name: 'Matt Simpson')
      #
      # @param [Hash] params the key/value pair hash to delete records by
      def delete_by_params(params)
        interface.delete_by_params(data_collection, params)
      end

      # Finds all records in the collection
      #
      # @returns [Array] all records in the collection, empty array if non found.
      def all
        translate_each_from_interface interface.find_all(data_collection)
      end

      # Returns all records in the collection that has the given field and value
      #
      # @param [Symbol] field the field to query for
      # @param [*] value the value to query on the field for
      # @returns [Array] the set of records matching the field / value pair
      def all_by_field(field, value)
        translate_each_from_interface interface.get_all_for_key_with_value(data_collection, field, value)
      end

      # Finds all recurds that match a set of key / value pairs
      #
      # @param [Hash] hash a hash of field / value pairs to query records for
      # @returns [Array] the set of records matching all key / value pairs
      def all_by_fields(hash)
        translate_each_from_interface interface.get_by_params(data_collection, hash)
      end

      # Finds One record that matches all of the field / value pairs
      #
      # @param [Hash] hash the hash to query for
      # @returns [Hash] a hash containing the data for the found record, nil is returned when nothing is found
      def find_by_fields(hash)
        translate_from_interface all_by_fields(hash).first
      end

      # Finds One record that matches a field / value pair
      #
      # @param [Symbol] field the field to query for
      # @param [*] value the value to query on the field for
      # @returns [Hash] a hash containing the data for the found record, nil is returned when nothing is found
      def find_by_field(field, value)
        translate_from_interface interface.get_for_key_with_value(data_collection, field, value)
      end

      # Finds all records where the field contains any of the values
      #
      # @param [Symbol] field the field to query against
      # @param [Array] values an array of values to get records for
      # @returns [Array] an array containing all records that match the criteria
      def containing_any(field, values)
        translate_each_from_interface interface.containing_any(data_collection, field, values)
      end

      # Finds all records where the field, which must be an array field, contains the value
      #
      # @param [Symbol] field the field to query against
      # @param [*] value the value to query against
      # @returns [Array] an array containing all records that match the criteria
      def array_contains(field, value)
        translate_each_from_interface interface.array_contains(data_collection, field, value)
      end

      # Deletes the entire collection from the database
      def delete_collection
        interface.delete_collection(data_collection)
      end

      def translate_from_interface(hash)
        if hash
          hash["id"] = hash[primary_key] if hash[primary_key]
          HashWithIndifferentAccess.new hash
        end
      end

      def translate_each_from_interface(data)
        data.collect {|d| translate_from_interface(d) }
      end

      private

      def primary_key
        @primary_key ||= interface.primary_key
      end

      def set_data_collection(collection_name)
        @data_collection = collection_name
      end

      def create_data_fields(*fields)
        attr_accessor *fields
        @data_fields = fields
      end
    end

    def initialize(model)
      @model = model
      set_data_field_values
      set_id
    end

    def interface
      self.class.interface
    end

    def data_fields
      self.class.data_fields
    end

    def data_collection
      self.class.data_collection
    end

    def add_to_interface
      interface.add(data_collection, attributes)
    end

    def replace_in_interface
      interface.replace(data_collection, attributes)
    end

    private

    def attributes
      model_instance_values.merge(primary_key => id)
    end

    def model_instance_values
      HashWithIndifferentAccess.new(model.instance_values).slice(*data_fields)
    end

    def set_id
      @id = model_has_id? ? model.id : generated_id
    end

    def generated_id
      interface.generate_unique_id(model)
    end

    def model_has_id?
      model.respond_to?(:id) && model.id
    end

    def set_data_field_values
      data_fields.each { |field| set_data_field_value(field) }
    end

    def primary_key
      interface.primary_key
    end

    def set_data_field_value(field)
      self.send("#{field}=", model.send(field)) if field_exists?(field)
    end

    def field_exists?(field)
      model.respond_to?(field) && !model.send(field).nil?
    end
  end
end
