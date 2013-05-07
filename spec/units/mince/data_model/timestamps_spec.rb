require_relative '../../../../lib/mince/data_model/timestamps'

module Mince::DataModel
  describe Timestamps, 'Mixin' do
    let(:klass) do
      Class.new do
        include Mince::DataModel
        include Timestamps

        data_collection :users
        data_fields :username, :emails
      end
    end
    let(:utc_now) { mock }
    let(:interface) { mock 'interface' }
    let(:data_collection) { mock 'collection name' }
    let(:primary_key) { mock 'primary key' }

    before do
      Time.stub_chain('now.utc' => utc_now)
      klass.stub(interface: interface, data_collection: data_collection, primary_key: primary_key) # because it's mixed in
    end

    describe 'adding a record' do
      let(:hash_to_add) { { username: 'joe' } }
      let(:unique_id) { mock }
      let(:expected_hash) do
        HashWithIndifferentAccess.new(
          hash_to_add.merge(
            primary_key => unique_id,
            created_at: utc_now,
            updated_at: utc_now
          )
        )
      end

      before do
        interface.stub(:add).with(data_collection, expected_hash).and_return([expected_hash])
        interface.stub(:generate_unique_id).with(hash_to_add).and_return(unique_id)
      end

      it 'sets the created at value' do
        klass.add(hash_to_add).should == expected_hash
      end
    end
  end
end
