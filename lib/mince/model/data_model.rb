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
    end
  end
end
