require 'debugger'
require 'mince'
require 'hashy_db'
require 'active_support/core_ext/numeric/time'

describe 'A data model with inferred fields' do
  subject { model_klass.new attributes }

  let(:attributes) { { brand: brand, price: price, type: type, color: color } }
  let(:brand) { mock }
  let(:price) { mock }
  let(:type) { mock }
  let(:color) { mock }

  before do
    Mince::Config.interface = Mince::HashyDb::Interface
    Mince::HashyDb::Interface.clear
  end

  after do
    Mince::HashyDb::Interface.clear
  end

  describe 'a model with a limited set of mince model mixins' do
    let(:model_klass) do
      Class.new do
        include Mince::Model

        data_model(
          Class.new do
            include Mince::DataModel

            data_collection :guitars
            infer_fields_from_model
          end
        )
        field :brand, assignable: true
        field :price, assignable: true
        field :type, assignable: true
        field :color, assignable: true
      end
    end

    it 'is initialized with the correct data' do
      subject.brand.should == brand
      subject.price.should == price
      subject.type.should == type
      subject.color.should == color
    end

    it 'persists the data when saved' do
      subject.save

      all = model_klass.all
      all.size.should == 1
      all.first.brand.should == brand
      all.first.price.should == price
      all.first.type.should == type
      all.first.color.should == color
    end
  end
end
