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
        # Sets or returns the data model class for the model
        def find_by_fields(*fields)
          raise 'not implemented'
        end

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
      end
    end
  end
end
