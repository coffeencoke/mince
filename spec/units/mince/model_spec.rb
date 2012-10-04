require_relative '../../../lib/mince/model'

describe Mince::Model do
  let(:klass) do
    Class.new do
      include Mince::Model

      data_model Class.new

      field :meh
      field :foo, assignable: true
      field :bar, assignable: false
      fields :baz, :qaaz
    end
  end

  let(:meh) { mock 'meh' }
  let(:foo) { mock 'foo' }
  let(:bar) { mock 'bar' }
  let(:baz) { mock 'baz' }
  let(:qaaz) { mock 'qaaz' }

  subject { klass.new(meh: meh, foo: foo, bar: bar, baz: baz, qaaz: qaaz) }

  it 'initializes the object and assigns values to the fields' do
    subject.meh.should == meh
    subject.foo.should == foo
    subject.bar.should == bar
    subject.baz.should == baz
    subject.qaaz.should == qaaz
  end

  it 'can set the assignable fields outside of the initilizer' do
    subject.foo = 'foo1'
    subject.foo.should == 'foo1'
    subject.attributes = { foo: 'foo2' }
    subject.foo.should == 'foo2'
  end

  it 'cannot set the readonly field outside of the initilizer' do
    subject.attributes = { bar: 'bar1' }
    subject.bar.should == bar
  end

  it 'fields are readonly by default' do
    subject.attributes = { meh: 'meh1' }
    subject.meh.should == meh
  end

  describe 'saving' do
    let(:id) { mock 'id' }
    let(:data_fields) { subject.fields }

    before do
      subject.data_model.stub(:data_fields).and_return(data_fields)
    end

    context 'when the model has fields that are not defined in the data model' do
      let(:data_fields) { subject.fields - extra_fields }
      let(:extra_fields) { subject.fields[0..-2] }

      it 'raises an exception with a message' do
        expect { subject.save }.to raise_error("Tried to save a #{subject.class.name} with fields not specified in #{subject.data_model.name}: #{extra_fields.join(', ')}")
      end
    end

    context 'when it has not yet been persisted to the mince data model' do
      before do
        subject.data_model.stub(:store => id)
      end

      it 'stores the model' do
        subject.data_model.should_receive(:store).with(subject).and_return(id)

        subject.save
      end

      it 'assigns the id' do
        subject.save

        subject.id.should == id
      end
    end

    context 'when it has already been persisted to the mince data model' do
      let(:subject) { klass.new(id: id) }

      it 'updates the model' do
        subject.data_model.should_receive(:update).with(subject)

        subject.save
      end
    end
  end

  describe "Query Methods:" do
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
end
