require_relative '../../../../lib/mince/data_model'

module Mince
  describe DataModel, 'Mixin' do
    let(:klass) do
      Class.new do
        include Mince::DataModel

        data_collection :users
        infer_fields_from_model
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

    describe 'adding a record from a model' do
      subject { klass.new(model) }
      let(:model) { mock 'model', instance_values: instance_values, fields: fields }
      let(:fields) { [:username, :emails] }
      let(:instance_values) { HashWithIndifferentAccess.new username: "joe", emails: ["joedawg@test.com"] }

      before do
        interface.stub(:add)
      end

      it 'sets the created value' do
        subject.create

        subject.attributes.should == instance_values
      end
    end
  end
end
