require 'active_support/hash_with_indifferent_access'
require 'active_support/core_ext/hash/slice'
require 'active_support/concern'

require_relative 'config'

module Mince
  module DataModel
    extend ActiveSupport::Concern

    included do
      attr_reader :id, :model
    end

    module ClassMethods
      def interface
        Config.interface
      end

      def data_fields(*fields)
        create_data_fields(*fields) if fields.any?
        @data_fields
      end

      def data_collection(collection_name = nil)
        set_data_collection(collection_name) if collection_name
        @data_collection
      end

      def store(model)
        new(model).tap do |p|
          p.add_to_interface
        end.id
      end

      def update(model)
        new(model).tap do |p|
          p.replace_in_interface
        end
      end

      def update_field_with_value(id, field, value)
        interface.update_field_with_value(data_collection, id, field, value)
      end

      def increment_field_by_amount(id, field, amount)
        interface.increment_field_by_amount(data_collection, id, field, amount)
      end

      def remove_from_array(id, field, value)
        interface.remove_from_array(data_collection, interface.primary_key, id, field, value)
      end

      def push_to_array(id, field, value)
        interface.push_to_array(data_collection, interface.primary_key, id, field, value)
      end

      def find(id)
        translate_from_interface interface.find(data_collection, interface.primary_key, id)
      end

      def delete_field(field)
        interface.delete_field(data_collection, field)
      end

      def delete_by_params(params)
        interface.delete_by_params(data_collection, params)
      end

      def all
        translate_each_from_interface interface.find_all(data_collection)
      end

      def all_by_field(field, value)
        translate_each_from_interface interface.get_all_for_key_with_value(data_collection, field, value)
      end

      def all_by_fields(hash)
        translate_each_from_interface interface.get_by_params(data_collection, hash)
      end

      def find_by_fields(hash)
        translate_from_interface all_by_fields(hash).first
      end                 

      def find_by_field(field, value)
        translate_from_interface interface.get_for_key_with_value(data_collection, field, value)
      end                 

      def containing_any(field, values)
        translate_each_from_interface interface.containing_any(data_collection, field, values)
      end

      def array_contains(field, value)
        translate_each_from_interface interface.array_contains(data_collection, field, value)
      end

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
