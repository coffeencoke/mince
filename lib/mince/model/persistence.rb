module Mince
  module Model
    require 'active_support'
    require 'active_model'
    require 'active_support/core_ext/module/delegation'
    require 'active_support/core_ext/object/instance_variables'

    module Persistence
      extend ActiveSupport::Concern

      included do
        include ActiveModel::Conversion
        extend ActiveModel::Naming
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

        # Creates a record with the given field values
        def create(data)
          new(data).tap(&:save)
        end
      end

      delegate :data_model, to: 'self.class'

      # Returns true if the record indicates that it has been persisted to a data model.
      # Returns false otherwise.
      def persisted?
        !!id
      end

      # Saves the object to the data model.  Stores if new, updates previous entry if it has already
      # been saved.
      def save
        ensure_no_extra_fields if self.respond_to?(:ensure_no_extra_fields)

        if persisted?
          data_model.update(self)
        else
          @id = data_model.store(self)
        end
      end
    end
  end
end
