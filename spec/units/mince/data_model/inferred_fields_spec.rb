require_relative '../../../../lib/mince/data_model'

module Mince  
  describe DataModel do
    subject { klass.new(model) }

    let(:model) { mock fields: fields}
    let(:fields) { [:username, :email] }
    let(:klass) do
      Class.new do
        include Mince::DataModel

        data_collection :users
      end
    end
    let(:id) { mock }

    before do
      klass.stub(:generate_unique_id).with(model).and_return(id)
    end

    context 'when the data model is infering fields' do
      let(:primary_key) { mock }
      let(:interface) { mock }
      let(:model_instance_values) { { username: 'coffeencoke' } }

      before do
        klass.stub(infer_fields?: true, interface: interface, primary_key: primary_key)
        model.stub(instance_values: model_instance_values)
      end

      its(:infer_fields?) { should be_true }

      it 'can store the model' do
        expected_attributes = HashWithIndifferentAccess.new(model_instance_values.merge(primary_key => id))
        interface.should_receive(:add).with(klass.data_collection, expected_attributes)

        subject.create.should == id
      end
    end

    context 'when the data model is not infering fields' do
      before do
        klass.stub(infer_fields?: false)
      end

      its(:infer_fields?) { should be_false }
    end
  end

  describe DataModel, 'Class Methods:' do
    subject { klass }

    context 'when the data model is infering fields' do
      let(:klass) do
        Class.new do
          include Mince::DataModel

          data_collection :users
          infer_fields_from_model
        end
      end

      its(:infer_fields?) { should be_true }
    end

    context 'when the data model is not infering fields' do
      let(:klass) do
        Class.new do
          include Mince::DataModel

          data_collection :users
        end
      end

      its(:infer_fields?) { should be_false }
    end
  end
end
