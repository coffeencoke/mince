require 'mince'
require 'hashy_db'
require 'active_support/core_ext/numeric/time'

describe 'A mince model integration spec' do
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
        include Mince::Model::Fields

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

    it 'is initialized with the correct data' do
      subject.brand.should == brand
      subject.price.should == price
      subject.type.should == type
      subject.color.should == color
    end

    it 'cannot be persisted to the mince data interface' do
      subject.respond_to?(:save).should be_false
    end
  end

  describe 'a model with all mince model mixins' do
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

    context 'when not all fields are defined in the data model' do
      let(:model_klass) do
        Class.new do
          include Mince::Model

          data_model(
            Class.new do
              include Mince::DataModel

              data_collection :guitars
              data_fields :brand, :price, :type
            end
          )
          fields :brand, :price, :type, :color
        end
      end

      it 'raises an exception to provide feedback about the missing field' do
        expect { subject.save }.to raise_exception(RuntimeError, "Tried to save a  with fields not specified in : color")
      end
    end
  end
end
