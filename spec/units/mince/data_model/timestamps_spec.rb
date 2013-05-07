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
    let(:id) { '1' }
    let(:primary_key) { mock 'primary key' }

    before do
      Time.stub_chain('now.utc' => utc_now)
      klass.stub(
        interface: interface,
        data_collection: data_collection,
        primary_key: primary_key,
        generate_unique_id: id
      ) # because it's mixed in
    end

    describe 'adding a record from a hash' do
      let(:hash_to_add) { { username: 'joe' } }
      let(:expected_hash) do
        HashWithIndifferentAccess.new(
          hash_to_add.merge(
            primary_key => id,
            created_at: utc_now,
            updated_at: utc_now
          )
        )
      end

      before do
        interface.stub(:add).with(data_collection, expected_hash).and_return([expected_hash])
      end

      it 'sets the created and updated values' do
        klass.add(hash_to_add).should == expected_hash
      end
    end

    describe 'adding a record from a model' do
      let(:subject) { klass.new(model) }
      let(:model) { mock 'model', instance_values: instance_values }
      let(:instance_values) { HashWithIndifferentAccess.new username: "joe", emails: ["joedawg@test.com"] }
      let(:attributes_plus_timestamps) { instance_values.merge(created_at: utc_now, updated_at: utc_now, primary_key => id) }

      before do
        interface.stub(:add)
      end

      it 'sets the created value' do
        subject.create

        subject.attributes.should == attributes_plus_timestamps
      end
    end
  end
end
