require 'mince'
require 'hashy_db'

describe 'A mince data model integration spec' do
  let(:attributes) { { brand: brand, price: price, type: type, color: color } }
  let(:brand) { mock }
  let(:price) { mock }
  let(:type) { mock }
  let(:color) { mock }
  let(:primary_key) { Mince::HashyDb::Interface.primary_key}

  let(:data_model_klass) do
    Class.new do
      include Mince::DataModel

      data_collection :guitars
      data_fields :brand, :price, :type, :color
    end
  end

  before do
    Mince::Config.interface = Mince::HashyDb::Interface
    Mince::HashyDb::Interface.clear
  end

  after do
    Mince::HashyDb::Interface.clear
  end

  it 'can insert data directly to the data collection' do
    data_model_klass.add attributes

    all = data_model_klass.all
    all.size.should == 1
    %w(brand price type color).each do |field|
      all.first[field.to_sym].should == attributes[field.to_sym]
    end
    all.first[primary_key].should_not be_nil
  end
end
