require_relative '../../mince'

shared_examples_for 'a mince interface' do
  describe 'Mince Interface v2' do
    let(:interface) { Mince::Config.interface }
    let(:primary_key) { interface.primary_key }

    let(:data1) { { primary_key => 1, field_1: 'value 1', field_2: 3, field_3: [1, 2, 3], shared_between_1_and_2: 'awesome_value', :some_array => [1, 2, 3, 4]} }
    let(:data2) { { primary_key => 2, field_1: 'value 1.2', field_2: 6, shared_between_1_and_2: 'awesome_value', :some_array => [4, 5, 6]} }
    let(:data3) { { primary_key => 3, field_1: 'value 3', field_2: 9, shared_between_1_and_2: 'not the same as 1 and 2', :some_array => [1, 7]} }

    before do
      interface.set_data({})

      interface.insert(:some_collection, [data1, data2, data3])
    end

    describe "Generating a primary key" do
      subject do 
        (1..number_of_records).map do |salt|
          interface.generate_unique_id(salt)
        end
      end

      let(:number_of_records) { 1000 }

      it 'creates a unique id' do
        subject.uniq.size.should == number_of_records
      end
    end

    it 'can delete a field' do
      interface.delete_field(:some_collection, :field_1)

      interface.find_all(:some_collection).each do |row|
        row.has_key?(:field_1).should be_false
      end
    end

    it 'can delete a collection' do
      interface.delete_collection(:some_collection)
      
      interface.find_all(:some_collection).should == []
    end

    it 'can delete records that match a given set of fields' do
      params = { primary_key =>1, field_1: 'value 1' }

      interface.delete_by_params(:some_collection, params)

      interface.find_all(:some_collection).should == [data2, data3]
    end

    it 'can write and read data to and from a collection' do
      data4 = {primary_key =>3, field_1: 'value 3', field_2: 9, shared_between_1_and_2: 'not the same as 1 and 2', :some_array => [1, 7]}

      interface.add(:some_collection, data4)
      interface.find_all(:some_collection).should == [data1, data2, data3, data4]
    end

    it 'can replace a record' do
      data2[:field_1] = 'value modified'
      interface.replace(:some_collection, data2)

      interface.find(:some_collection, primary_key, 2)[:field_1].should == 'value modified'
    end

    it 'can update a field with a value on a specific record' do
      interface.update_field_with_value(:some_collection, 3, :field_2, '10')
      
      interface.find(:some_collection, primary_key, 3)[:field_2].should == '10'
    end

    it 'can increment a field with a given amount for a specific field' do
      interface.increment_field_by_amount(:some_collection, 1, :field_2, 3)
      
      interface.find(:some_collection, primary_key, 1)[:field_2].should == 6
    end

    it 'can get one document' do
      interface.find(:some_collection, :field_1, 'value 1').should == data1
      interface.find(:some_collection, :field_2, 6).should == data2
    end

    it 'can clear the data store' do
      interface.clear

      interface.find_all(:some_collection).should == []
    end

    it 'can get all records of a specific key value' do
      interface.get_all_for_key_with_value(:some_collection, :shared_between_1_and_2, 'awesome_value').should == [data1, data2]
    end

    it 'can get all records where a value includes any of a set of values' do
      interface.containing_any(:some_collection, :some_array, []).should == []
      interface.containing_any(:some_collection, :some_array, [7, 2, 3]).should == [data1, data3]
      interface.containing_any(:some_collection, primary_key, [1, 2, 5]).should == [data1, data2]
    end

    it 'can get all records where the array includes a value' do
      interface.array_contains(:some_collection, :some_array, 1).should == [data1, data3]
      interface.array_contains(:some_collection, :some_array_2, 1).should == []
    end

    it 'can push a value to an array for a specific record' do
      interface.push_to_array(:some_collection, primary_key, 1, :field_3, 'add to existing array')
      interface.push_to_array(:some_collection, primary_key, 1, :new_field, 'add to new array')

      interface.find(:some_collection, primary_key, 1)[:field_3].should include('add to existing array')
      interface.find(:some_collection, primary_key, 1)[:new_field].should == ['add to new array']
    end

    it 'can remove a value from an array for a specific record' do
      interface.remove_from_array(:some_collection, primary_key, 1, :field_3, 2)

      interface.find(:some_collection, primary_key, 1)[:field_3].should_not include(2)
    end

    it 'can get all records that match a given set of keys and values' do
      records = interface.get_by_params(:some_collection, field_1: 'value 1', shared_between_1_and_2: 'awesome_value')
      records.size.should be(1)
      records.first[primary_key].should == 1
      interface.find_all(:some_collection).size.should == 3
    end

    it 'can get a record for a specific key and value' do
      interface.get_for_key_with_value(:some_collection, :field_1, 'value 1').should == data1
    end
  end
end

