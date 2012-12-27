module Mince
  module Model
    require 'active_support'
    require 'active_support/core_ext/module/delegation'
    require 'active_support/core_ext/object/instance_variables'
    require_relative 'data_model'

    module Fields
      extend ActiveSupport::Concern

      included do
        include Mince::Model::DataModel

        attr_accessor :id
      end

      module ClassMethods
        # Adds a field to the object.  Takes options to indicate assignability.  If `assignable`
        # is set, the field will be assignable via 
        #   model.field = 'foo'
        #   model.attributes = { field: 'foo' }
        #
        def field(field_name, options={})
          if options[:assignable]
            add_assignable_field(field_name)
          else
            add_readonly_field(field_name)
          end
        end

        # Adds a read only field, values for these fields can only be set in the class itself
        # or from the hash sent in to the initializer
        def add_readonly_field(field_name)
          fields << field_name
          readonly_fields << field_name
          attr_reader field_name
        end

        # Adds an assignable field, values for these fields can be set using the field writer
        # or from the `attributes=` method.
        def add_assignable_field(field_name)
          fields << field_name
          assignable_fields << field_name
          attr_accessor field_name
        end

        # Adds multiple readonly fields to the fields array, and returns the current list
        # of fields.  If no fields are given, it just returns the current list of fields
        def fields(*field_names)
          @fields ||= []
          field_names.each {|field_name| field(field_name) }
          @fields
        end

        # Returns the list of assignable fields
        def assignable_fields
          @assignable_fields ||= []
        end

        # Returns the list of readonly fields
        def readonly_fields
          @readonly_fields ||= []
        end
      end

      delegate :assignable_fields, :readonly_fields, :fields, to: 'self.class'

      # Sets values (for fields defined by calling .field or .fields) in the hash to the object 
      # includes assignable and non-assignable fields
      def initialize(hash={})
        @id = hash[:id]
        readonly_fields.each do |field_name|
          self.instance_variable_set("@#{field_name}", hash[field_name]) if hash[field_name]
        end
        self.attributes = hash
      end

      # Sets values (for assignable fields only, defined by calling .field or .fields) in the hash
      # to the object.
      #
      # Allows the proxy to have whitelisted attributes to be assigned from http requests.
      def attributes=(hash={})
        assignable_fields.each do |field|
          send("#{field}=", hash[field]) if hash[field]
        end
      end

      protected

      # Ensures that the data model has all of the fields that are trying to be saved. Raises an
      # exception if the data model does not.
      def ensure_no_extra_fields
        extra_fields = (fields - data_model.data_fields)
        if extra_fields.any?
          raise "Tried to save a #{self.class.name} with fields not specified in #{data_model.name}: #{extra_fields.join(', ')}"
        end
      end
    end
  end
end
