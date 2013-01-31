require_relative '../../../lib/mince/data_model'
require 'digest'

describe Mince::DataModel, 'Mixin' do
  let(:described_class) { klass }

  let(:collection_name) { :guitars }
  let(:data_field_attributes) do
    {
            brand: 'a brand everyone knows',
            price: 'a price you save up for',
            type: 'the kind you want',
            color: 'should be your favorite'
    }
  end

  let(:klass) do
    Class.new do
      include Mince::DataModel

      data_collection :guitars
      data_fields :brand, :price, :type, :color
    end
  end

  let(:interface) { mock 'mince data interface class', generate_unique_id: unique_id, primary_key: primary_key }
  let(:unique_id) { mock 'id' }
  let(:primary_key) { "custom_id" }

  before do
    Mince::Config.stub(:interface => interface)
  end

  describe "storing a data model" do
    let(:model) { mock 'a model', instance_values: data_field_attributes }

    before do
      interface.stub(:add)
    end

    it 'generates a unique id using the model as a salt' do
      interface.should_receive(:generate_unique_id).with(model).and_return(unique_id)

      described_class.store(model)
    end

    it 'adds the data model to the db store' do
      interface.should_receive(:add).with(collection_name, HashWithIndifferentAccess.new({primary_key => unique_id}).merge(data_field_attributes))

      described_class.store(model)
    end
  end

  it 'can delete the collection' do
    interface.should_receive(:delete_collection).with(collection_name)
    
    described_class.delete_collection
  end

  it 'can delete a field' do
    field = mock 'field to delete from the collection'

    interface.should_receive(:delete_field).with(collection_name, field)

    described_class.delete_field(field)
  end

  it 'can delete records by a given set of params' do
    params = mock 'params that provide a condition of what records to delete from the collection'

    interface.should_receive(:delete_by_params).with(collection_name, params)

    described_class.delete_by_params(params)
  end

  describe "updating a data model" do
    let(:data_model_id) { '1234567' }
    let(:model) { mock 'a model', id: data_model_id, instance_values: data_field_attributes }

    before do
      interface.stub(:replace)
    end

    it 'replaces the data model in the db store' do
      interface.should_receive(:replace).with(collection_name, HashWithIndifferentAccess.new({primary_key => data_model_id}).merge(data_field_attributes))

      described_class.update(model)
    end
  end

  describe 'updating a specific field for a data model' do
    let(:data_model_id) { '1234567' }
    
    it 'has the data store update the field' do
      interface.should_receive(:update_field_with_value).with(collection_name, data_model_id, :some_field, 'some value')

      described_class.update_field_with_value(data_model_id, :some_field, 'some value')
    end
  end

  describe 'incrementing a specific field by a given an amount' do
    let(:data_model_id) { mock 'id' }

    it 'has the data store update the field' do
      interface.should_receive(:increment_field_by_amount).with(collection_name, data_model_id, :some_field, 4)

      described_class.increment_field_by_amount(data_model_id, :some_field, 4)
    end
  end

  describe "pushing a value to an array for a data model" do
    let(:data_model_id) { '1234567' }

    it 'replaces the data model in the db store' do
      interface.should_receive(:push_to_array).with(collection_name, data_model_id, :array_field, 'some value')

      described_class.push_to_array(data_model_id, :array_field, 'some value')
    end
  end

  describe "getting all data models with a specific value for a field" do
    let(:data_model) { {primary_key => 'some id'} }
    let(:expected_data_models) { [HashWithIndifferentAccess.new({:id => 'some id', primary_key => 'some id'})] }
    let(:data_models) { [data_model] }
    subject { described_class.array_contains(:some_field, 'some value') }

    it 'returns the stored data models with the requested field / value' do
      interface.should_receive(:array_contains).with(collection_name, :some_field, 'some value').and_return(data_models)

      subject.should == expected_data_models
    end
  end

  describe "removing a value from an array for a data model" do
    let(:data_model_id) { '1234567' }

    it 'removes the value from the array' do
      interface.should_receive(:remove_from_array).with(collection_name, data_model_id, :array_field, 'some value')

      described_class.remove_from_array(data_model_id, :array_field, 'some value')
    end
  end

  describe 'getting all of the data models' do
    let(:data_model) { {primary_key => 'some id'} }
    let(:expected_data_models) { [HashWithIndifferentAccess.new({:id => 'some id', primary_key => 'some id'})] }
    let(:data_models) { [data_model] }

    it 'returns the stored data models' do
      interface.should_receive(:find_all).with(collection_name).and_return(data_models)

      described_class.all.should == expected_data_models
    end
  end

  describe "getting all the data fields by a parameter hash" do
    let(:data_model) { {primary_key => 'some id'} }
    let(:expected_data_models) { [{:id => 'some id', primary_key => 'some id'}] }
    let(:data_models) { [data_model] }
    let(:expected_data_models) { [HashWithIndifferentAccess.new(data_model)] }

    it 'passes the hash to the interface_class' do
      interface.should_receive(:get_all_for_key_with_value).with(collection_name, :field2, 'not nil').and_return(data_models)

      described_class.all_by_field(:field2, 'not nil').should == expected_data_models
    end
  end

  describe "getting a record by a set of key values" do
    let(:data_model) { {primary_key => 'some id'} }
    let(:data_models) { [data_model] }
    let(:expected_data_models) { [{:id => 'some id', primary_key => 'some id'}] }

    let(:sample_hash) { {field1: nil, field2: 'not nil'} }

    it 'passes the hash to the interface_class' do
      interface.should_receive(:get_by_params).with(collection_name, sample_hash).and_return(data_models)

      described_class.find_by_fields(sample_hash).should == HashWithIndifferentAccess.new(expected_data_models.first)
    end
  end

  describe "getting all of the data models for a where a field contains any value of a given array of values" do
    let(:data_models) { [{primary_key => 'some id'}, {primary_key => 'some id 2'}] }
    let(:expected_data_models) { [{"id" => 'some id', primary_key => 'some id'}, {"id" => 'some id 2', primary_key => 'some id 2'}] }

    subject { described_class.containing_any(:some_field, ['value 1', 'value 2']) }

    it 'returns the stored data models' do
      interface.should_receive(:containing_any).with(collection_name, :some_field, ['value 1', 'value 2']).and_return(data_models)

      subject.should == expected_data_models
    end
  end

  describe "getting a record by a key and value" do
    let(:data_model) { {primary_key => 'some id'} }
    let(:expected_data_model) { {:id => 'some id', primary_key => 'some id'} }

    it 'returns the correct data model' do
      interface.should_receive(:get_for_key_with_value).with(collection_name, :field2, 'not nil').and_return(data_model)

      described_class.find_by_field(:field2, 'not nil').should == HashWithIndifferentAccess.new(expected_data_model)
    end
  end

  describe "getting all data models with a specific value for a field" do
    let(:data_models) { [{primary_key => 'some id'}, {primary_key => 'some id 2'}] }
    let(:expected_data_models) { [HashWithIndifferentAccess.new({:id => 'some id', primary_key => 'some id'}), HashWithIndifferentAccess.new({id: 'some id 2', primary_key => 'some id 2'})] }
    subject { described_class.all_by_field(:some_field, 'some value') }

    it 'returns the stored data models with the requested field / value' do
      interface.should_receive(:get_all_for_key_with_value).with(collection_name, :some_field, 'some value').and_return(data_models)

      subject.should == expected_data_models
    end
  end

  describe 'getting a specific data model' do
    let(:data_model) { {primary_key => 'id', :id => 'id' } }

    it 'returns the data model from the data store' do
      interface.should_receive(:find).with(collection_name, 'id').and_return(data_model)

      described_class.find(data_model[:id]).should == HashWithIndifferentAccess.new(data_model)
    end
  end
end
