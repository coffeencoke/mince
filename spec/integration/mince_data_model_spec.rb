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
    result = data_model_klass.add attributes

    all = data_model_klass.all
    all.size.should == 1
    [all.first, result].each do |object|
      %w(brand price type color).each do |field|
        object[field.to_sym].should == attributes[field.to_sym]
      end
      object[primary_key].should_not be_nil
    end
  end

  describe 'a mince data model with timestamps' do
    subject { data_model_klass.new brand: mock }

    let(:data_model_klass) do
      Class.new do
        include Mince::DataModel
        include Mince::DataModel::Timestamps

        data_collection :guitars
        data_fields :brand
      end
    end

    it 'provides a data field for the timestamps' do
      subject.created_at.should be_nil
      subject.updated_at.should be_nil
      subject.data_fields.should =~ [:brand, :updated_at, :created_at]
    end

    context 'when the record is created' do
      let(:persisted_data_model) { data_model_klass.find_by_field :brand, brand }
      let(:brand) { 'Gibson' }

      before do
        data_model_klass.add brand: brand
      end

      it 'sets the created at timestamp' do
        (persisted_data_model[:created_at] > 10.seconds.ago.utc && persisted_data_model[:created_at] < 10.seconds.from_now.utc).should be_true
      end

      it 'sets the updated at timestamp' do
        (persisted_data_model[:updated_at] > 10.seconds.ago.utc && persisted_data_model[:updated_at] < 10.seconds.from_now.utc).should be_true
      end
    end

    context 'when the record is updated' do
      let(:persisted_data_model) { data_model_klass.find_by_field :brand, brand }
      let(:brand) { 'Gibson' }

      before do
        data_model_klass.add brand: brand
        data_model_klass.update_field_with_value persisted_data_model[:id], :updated_at, (Time.now - 10000).utc
      end

      it 'updates the updated at timestamp' do
        persisted_data_model = data_model_klass.find_by_field(:brand, brand)
        (persisted_data_model[:updated_at] > 10.seconds.ago.utc && persisted_data_model[:updated_at] < 10.seconds.from_now.utc).should be_true
      end
    end
  end
end
