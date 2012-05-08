# SRP: Model with implementation on how to store each collection in a data store
require 'singleton'

require_relative 'connection'

module Mince
  class DataStore
    include Singleton

    def self.primary_key_identifier
      '_id'
    end

    def self.generate_unique_id(*args)
      BSON::ObjectId.new.to_s
    end

    def add(collection_name, hash)
      collection(collection_name).insert(hash)
    end

    def replace(collection_name, hash)
      collection(collection_name).update({"_id" => hash[:_id]}, hash)
    end

    def update_field_with_value(*args)
      raise %(The method `Mince::DataStore.singleton.update_field_with_value` is not implemented, you should implement it for us!)
    end

    def get_all_for_key_with_value(collection_name, key, value)
      get_by_params(collection_name, key.to_s => value)
    end

    def get_for_key_with_value(collection_name, key, value)
      get_all_for_key_with_value(collection_name, key, value).first
    end

    def get_by_params(collection_name, hash)
      collection(collection_name).find(hash)
    end

    def find_all(collection_name)
      collection(collection_name).find
    end

    def find(collection_name, key, value)
      collection(collection_name).find_one({key.to_s => value})
    end

    def push_to_array(collection_name, identifying_key, identifying_value, array_key, value_to_push)
      collection(collection_name).update({identifying_key.to_s => identifying_value}, {'$push' => {array_key.to_s => value_to_push}})
    end

    def remove_from_array(collection_name, identifying_key, identifying_value, array_key, value_to_remove)
      collection(collection_name).update({identifying_key.to_s => identifying_value}, {'$pull' => {array_key.to_s => value_to_remove}})
    end

    def containing_any(collection_name, key, values)
      collection(collection_name).find({key.to_s => {"$in" => values}})
    end

    def array_contains(collection_name, key, value)
      collection(collection_name).find(key.to_s => value)
    end

    def clear
      db.collection_names.each do |collection_name|
        db.drop_collection collection_name unless collection_name.include?('system')
      end
    end

    def collection(collection_name)
      db.collection(collection_name)
    end

    def insert(collection_name, data)
      data.each do |datum|
        add collection_name, datum
      end
    end

    def db
      Mince::Connection.instance.db
    end
  end
end
