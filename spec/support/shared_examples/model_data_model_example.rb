shared_examples_for 'a model using mince model data model' do
  before do
    begin
      klass
    rescue NameError
      raise "You must define a `klass` spec variable to use the mince model finders shared example"
    end
  end

  it 'can set and get the data model' do
    data_model = mock 'data model'
    klass.data_model(data_model)
    klass.data_model.should == data_model
  end
end

