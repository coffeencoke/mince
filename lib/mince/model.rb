require 'active_support'
require 'active_model'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/object/instance_variables'

module Mince
 module Model
    extend ActiveSupport::Concern

    included do
      include ActiveModel::Conversion
      extend ActiveModel::Naming

      attr_accessor :id
    end

    module ClassMethods
      def data_model(model=nil)
        @data_model = model if model
        @data_model
      end

      def all
        data_model.all.map{|a| new a }
      end

      def find(id)
        a = data_model.find(id)
        new a if a
      end

      def field(field_name, options={})
        if options[:assignable]
          add_assignable_field(field_name)
        else
          add_readonly_field(field_name)
        end
      end

      def add_readonly_field(field_name)
        fields << field_name
        readonly_fields << field_name
        attr_reader field_name
      end

      def add_assignable_field(field_name)
        fields << field_name
        assignable_fields << field_name
        attr_accessor field_name
      end

      def fields(*field_names)
        @fields ||= []
        field_names.each {|field_name| field(field_name) }
        @fields
      end

      def assignable_fields
        @assignable_fields ||= []
      end

      def readonly_fields
        @readonly_fields ||= []
      end
    end

    delegate :data_model, :assignable_fields, :readonly_fields, :fields, to: 'self.class'

    def initialize(hash={})
      @id = hash[:id]
      readonly_fields.each do |field_name|
        self.instance_variable_set("@#{field_name}", hash[field_name]) if hash[field_name]
      end
      self.attributes = hash
    end

    def persisted?
      !!id
    end

    def save
      ensure_no_extra_fields
      if persisted?
        data_model.update(self)
      else
        @id = data_model.store(self)
      end
    end

    def ensure_no_extra_fields
      extra_fields = (fields - data_model.data_fields)
      if extra_fields.any?
        raise "Tried to save a #{self.class.name} with fields not specified in #{data_model.name}: #{extra_fields.join(', ')}"
      end
    end

    def attributes=(hash={})
      assignable_fields.each do |field|
        send("#{field}=", hash[field]) if hash[field]
      end
    end
  end
end
