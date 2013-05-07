module Mince
  module DataModel
    require 'active_support/concern'
    require_relative '../data_model'

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
        def add_timestamps_to_hash(hash)
          now = Time.now.utc
          hash.merge!(created_at: now, updated_at: now)
        end

        def set_update_timestamp_for(data_collection, id)
          interface.update_field_with_value(data_collection, id, :updated_at, Time.now.utc)
        end
      end

      def update_timestamps
        now = Time.now.utc
        self.created_at = now unless created_at
        self.updated_at = now
      end

      def timestamp_attributes
        { created_at: created_at, updated_at: updated_at }
      end
    end
  end
end
