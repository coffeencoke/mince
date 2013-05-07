module Mince
  module DataModel
    # = Timestamps
    #
    # Timestamps can be mixed into your DataModel classes in order to provide with fields
    # to store when records are created and updated.
    #
    # Example:
    #   require 'mince/data_model'
    #
    #   Class UserDataModel
    #     include Mince::DataModel
    #     include Mince::DataModel::Timestamps
    #
    #     data_collection :users
    #     data_fields :username
    #   end
    #
    #   UserDataModel.add username: 'coffeencoke'
    #   data_model = UserDataModel.find_by_field :username, 'coffeencoke'
    #   data_model.created_at # => todo: returns date time in utc
    #   data_model.updated_at # => todo: returns date time in utc
    #
    # Whenever a database persisting message is called for a record, the updated_at
    # timestamp will be updated.
    module Timestamps
      include Mince::DataModel

      extend ActiveSupport::Concern

      included do
        data_fields :created_at, :updated_at
      end

      module ClassMethods # :nodoc:
        def update_timestamps(hash)
          now = Time.now.utc
          hash.merge!(created_at: now, updated_at: now)
        end
      end
    end
  end
end
