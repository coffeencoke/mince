module Mince
  module Model
    require 'active_support'
    require 'active_model'
    require 'active_support/core_ext/module/delegation'
    require_relative 'data_model'

    module Persistence
      extend ActiveSupport::Concern

      included do
        include Mince::Model::DataModel
        include ActiveModel::Conversion
        extend ActiveModel::Naming
      end

      module ClassMethods
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
        ensure_no_extra_fields if self.respond_to?(:ensure_no_extra_fields, true)

        if persisted?
          data_model.update(self)
        else
          @id = data_model.store(self)
        end
      end
    end
  end
end
