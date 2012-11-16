shared_examples_for 'a model using mince model finders' do
  before do
    begin
      klass
    rescue NameError
      raise "You must define a `klass` spec variable to use the mince model finders shared example"
    end
  end

  describe 'getting all models' do
    subject { klass.all }

    let(:model) { mock }
    let(:models) { [model] }
    let(:data) { [datum] }
    let(:datum) { mock }

    before do
      klass.data_model.stub(all: data)
      klass.stub(:new).with(datum).and_return(model)
    end

    it 'returns an array of all models' do
      subject.should == models
    end
  end

  describe 'finding a model by id' do
    subject { klass.find(id) }

    let(:id) { mock 'id' }

    before do
      klass.data_model.stub(:find).with(id).and_return(data)
    end

    context 'when it exists' do
      let(:data) { mock 'data' }
      let(:model) { mock 'model' }

      before do
        klass.stub(:new).with(data).and_return(model)
      end

      it 'returns the model' do
        subject.should == model
      end
    end

    context 'when it does not exist' do
      let(:data) { nil }

      it 'returns nothing' do
        subject.should be_nil
      end
    end
  end
end

