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
    let(:utc_now) { mock 'now' }
    let(:interface) { mock 'interface' }
    let(:data_collection) { mock 'collection name' }
    let(:id) { '1' }
    let(:primary_key) { :id }

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
      subject { klass.new(model) }
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

    describe 'updating a record' do
      subject { klass.new(model) }
      let(:model) { mock 'model', instance_values.merge(instance_values: instance_values) }
      let(:instance_values) { HashWithIndifferentAccess.new username: "joe", emails: ["joedawg@test.com"], updated_at: 'old value', created_at: 'created time', primary_key => id }
      let(:attributes_plus_timestamp) { instance_values.merge(updated_at: utc_now) }

      before do
        interface.stub(:replace)
      end

      it 'sets the updated value' do
        subject.update

        subject.attributes.should == attributes_plus_timestamp
      end
    end

    describe 'updating a single field' do
      subject { klass.new(model) }
      let(:field_to_update) { :username }
      let(:new_value) { mock 'new value' }

      before do
        interface.stub(:update_field_with_value).with(data_collection, id, field_to_update, new_value)
      end

      it 'sets the updated value' do
        interface.should_receive(:update_field_with_value).with(data_collection, id, :updated_at, utc_now)

        klass.update_field_with_value(id, field_to_update, new_value)
      end
    end

    describe 'incrementing a single field' do
      subject { klass.new(model) }
      let(:field_to_update) { :username }
      let(:amount) { mock :amount }

      before do
        interface.stub(:increment_field_by_amount).with(data_collection, id, field_to_update, amount)
      end

      it 'sets the updated value' do
        interface.should_receive(:update_field_with_value).with(data_collection, id, :updated_at, utc_now)

        klass.increment_field_by_amount(id, field_to_update, amount)
      end
    end

    describe 'removing a value from an array field' do
      subject { klass.new(model) }
      let(:field_to_update) { :username }
      let(:value) { mock :value }

      before do
        interface.stub(:remove_from_array).with(data_collection, id, field_to_update, value)
      end

      it 'sets the updated value' do
        interface.should_receive(:update_field_with_value).with(data_collection, id, :updated_at, utc_now)

        klass.remove_from_array(id, field_to_update, value)
      end
    end
  end
end
