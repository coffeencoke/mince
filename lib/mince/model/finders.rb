module Mince
  module Model
    require 'active_support'
    require_relative 'data_model'

    module Finders
      extend ActiveSupport::Concern

      included do
        include Mince::Model::DataModel
      end

      module ClassMethods
        # Finds a model for the given field value pair
        def find_by_field(field, value)
          d = data_model.find_by_field(field, value)
          new d if d
        end

        # Finds a model for the given hash
        def find_by_fields(hash)
          d = data_model.find_by_fields(hash)
          new d if d
        end

        # Finds all fields that match the given field value pair
        def all_by_field(field, value)
          data_model.all_by_field(field, value).map{|a| new(a) }
        end

        # Finds all fields that match the given hash
        def all_by_fields(hash)
          data_model.all_by_fields(hash).map{|a| new(a) }
        end

        # Finds or initializes a model for the given hash
        def find_or_initialize_by(hash)
          find_by_fields(hash) || new(hash)
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

        # Returns all models where the field has a value that is less than the given value
        def all_before(field, value)
          data_model.all_before(field, value).map{|a| new(a) }
        end
      end
    end
  end
end
