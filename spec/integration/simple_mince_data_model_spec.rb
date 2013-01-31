require 'mince'
require 'hashy_db'

describe 'A simple mince data model integration spec' do
  before do
    Mince::Config.interface = Mince::HashyDb::Interface
    Mince::HashyDb::Interface.clear
  end

  after do
    Mince::HashyDb::Interface.clear
  end

  describe 'a model' do
    subject { model_klass.new attributes }

    let(:model_klass) do
      Class.new do
        include Mince::Model

        data_model(
          Class.new do
            include Mince::DataModel

            data_collection :guitars
            data_fields :brand, :price, :type, :color
          end
        )
        fields :brand, :price, :type, :color
      end
    end

    let(:attributes) { { brand: brand, price: price, type: type, color: color } }
    let(:brand) { mock }
    let(:price) { mock }
    let(:type) { mock }
    let(:color) { mock }

    it 'is initialized with the correct data' do
      subject.brand.should == brand
      subject.price.should == price
      subject.type.should == type
      subject.color.should == color
    end

    it 'can be persisted to the mince data interface' do
      subject.save

      raw_record = Mince::Config.interface.find(:guitars, subject.id)
      model_record = model_klass.find(subject.id)
      raw_record[:brand].should == brand
      model_record.brand.should == brand
    end
  end
end
