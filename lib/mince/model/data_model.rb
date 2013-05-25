module Mince
  module Model
    require 'active_support'

    module DataModel
      extend ActiveSupport::Concern

      module ClassMethods
        # Sets or returns the data model class for the model
        def data_model(model=nil)
          @data_model = model if model
          @data_model
        end
      end

      protected

      # Ensures that the data model has all of the fields that are trying to be saved. Raises an
      # exception if the data model does not.
      #
      # Not sure if this is where this method should live, it requires both
      # Mince::Model::DataModel and Mince::Model::Fields.
      def ensure_no_extra_fields
        if !data_model.infer_fields? && extra_fields.any?
          raise "Tried to save a #{self.class.name} with fields not specified in #{data_model.name}: #{extra_fields.join(', ')}"
        end
      end

      def extra_fields
        @extra_fields ||= (fields - data_model.data_fields)
      end
    end
  end
end
