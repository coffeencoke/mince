shared_examples_for 'a model using mince model finders' do
  before do
    begin
      klass
    rescue NameError
      raise "You must define a `klass` spec variable to use the mince model finders shared example"
    end
  end

  describe 'finding by one field' do
    subject { klass.find_by_field(field, value) }

    let(:field) { mock }
    let(:value) { mock }

    before do
      klass.data_model.stub(:find_by_field).with(field, value).and_return(data)
    end

    context 'when a record exists' do
      let(:data) { mock }
      let(:model) { mock }

      before do
        klass.stub(:new).with(data).and_return(model)
      end

      it { should == model }
    end

    context 'when a record does not exist' do
      let(:data) { nil }

      it { should be_nil }
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

    it { should == models }
  end

  describe 'finding all by fields' do
    subject { klass.all_by_fields(hash) }

    let(:hash) { mock }

    before do
      klass.data_model.stub(:all_by_fields).with(hash).and_return(data)
    end

    context 'when a record exists' do
      let(:data) { [mock] }
      let(:model) { mock }

      before do
        klass.stub(:new).with(data.first).and_return(model)
      end

      it { should == [model] }
    end

    context 'when a record does not exist' do
      let(:data) { [] }

      it { should be_empty }
    end
  end

  describe 'finding by fields' do
    subject { klass.find_by_fields(hash) }

    let(:hash) { mock }

    before do
      klass.data_model.stub(:find_by_fields).with(hash).and_return(data)
    end

    context 'when a record exists' do
      let(:data) { mock }
      let(:model) { mock }

      before do
        klass.stub(:new).with(data).and_return(model)
      end

      it { should == model }
    end

    context 'when a record does not exist' do
      let(:data) { nil }

      it { should be_nil }
    end
  end

  describe 'finding or initializing by fields' do
    subject { klass.find_or_initialize_by(hash) }

    let(:hash) { mock }

    before do
      klass.stub(:find_by_fields).with(hash).and_return(model)
    end

    context 'when a record exists' do
      let(:model) { mock }

      it { should == model }
    end

    context 'when a record does not exist' do
      let(:model) { nil }
      let(:new_model) { mock }

      before do
        klass.stub(:new).with(hash).and_return(new_model)
      end

      it { should == new_model }
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

      it { should == model }
    end

    context 'when it does not exist' do
      let(:data) { nil }

      it { should be_nil }
    end
  end
end

