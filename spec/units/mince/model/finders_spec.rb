require_relative '../../../../lib/mince/model/finders'
require_relative '../../../support/shared_examples/model_finders_example'

describe Mince::Model::Finders do
  let(:klass) do
    Class.new do
      include Mince::Model::Finders

      data_model Class.new
    end
  end

  it_behaves_like 'a model using mince model finders'
end
