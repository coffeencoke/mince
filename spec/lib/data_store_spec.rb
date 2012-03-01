require_relative '../../lib/mince/data_store'

describe Mince::DataStore do
  subject { described_class.instance }

  let(:db) { mock 'mongo database', collection: collection }
  let(:connection) { mock 'mongo connection', db: db }
  let(:mongo_data_store_connection) { mock 'mongo_data_store_connection', :db => db}
  let(:collection) { mock 'some collection'}
  let(:collection_name) { 'some_collection_name'}
  let(:primary_key) { mock 'primary key'}
  let(:mock_id) { mock 'id' }
  let(:data) { { :_id => mock_id}}
  let(:return_data) { mock 'return data' }

  before do
    Mince::Connection.stub(:instance => mongo_data_store_connection)
  end

  it 'uses the correct collection' do
    db.stub(collection: collection)
    subject.collection('collection name').should == collection
  end

  it 'has a primary key identifier' do
    described_class.primary_key_identifier.should == '_id'
  end

  describe "Generating a primary key" do
    let(:unique_id) { mock 'id' }
    it 'should create a reasonably unique id' do
      BSON::ObjectId.should_receive(:new).and_return(unique_id)

      described_class.generate_unique_id('something').should == unique_id.to_s
    end
  end

  it 'can write to the collection' do
    collection.should_receive(:insert).with(data).and_return(return_data)

    subject.add(collection_name, data).should == return_data
  end

  it 'can read from the collection' do
    collection.should_receive(:find).and_return(return_data)

    subject.find_all(collection_name).should == return_data
  end

  it 'can replace a record' do
    collection.should_receive(:update).with({"_id" => data[:_id]}, data)

    subject.replace(collection_name, data)
  end

  it 'can get one document' do
    field = "stuff"
    value = "more stuff"

    collection.should_receive(:find_one).with(field => value).and_return(return_data)

    subject.find(collection_name, field, value).should == return_data
  end

  it 'can clear the data store' do
    collection_names = %w(collection_1 collection_2 system_profiles)
    db.stub(:collection_names => collection_names)

    db.should_receive(:drop_collection).with('collection_1')
    db.should_receive(:drop_collection).with('collection_2')

    subject.clear
  end

  it 'can get all records of a specific key value' do
    collection.should_receive(:find).with({"key" => "value"}).and_return(return_data)

    subject.get_all_for_key_with_value(collection_name, "key", "value").should == return_data
  end

  it 'can get all records where a value includes any of a set of values' do
    collection.should_receive(:find).with({"key1" => { "$in" => [1,2,4]} }).and_return(return_data)

    subject.containing_any(collection_name, "key1", [1,2,4]).should == return_data
  end

  it 'can get all records where the array includes a value' do
    collection.should_receive(:find).with({"key" => "value"}).and_return(return_data)

    subject.array_contains(collection_name, "key", "value").should == return_data
  end

  it 'can push a value to an array for a specific record' do
    collection.should_receive(:update).with({"key" => "value"}, { '$push' => { "array_key" => "value_to_push"}}).and_return(return_data)

    subject.push_to_array(collection_name, :key, "value", :array_key, "value_to_push").should == return_data
  end

  it 'can remove a value from an array for a specific record' do
    collection.should_receive(:update).with({"key" => "value"}, { '$pull' => { "array_key" => "value_to_remove"}}).and_return(return_data)

    subject.remove_from_array(collection_name, :key, "value", :array_key, "value_to_remove").should == return_data
  end
end