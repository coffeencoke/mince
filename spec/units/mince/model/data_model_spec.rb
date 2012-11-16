require_relative '../../../../lib/mince/model/data_model'
require_relative '../../../support/shared_examples/model_data_model_example'

describe Mince::Model::DataModel do
  let(:klass) do
    Class.new do
      include Mince::Model::DataModel

      data_model Class.new
    end
  end

  it_behaves_like 'a model using mince model data model'
end
