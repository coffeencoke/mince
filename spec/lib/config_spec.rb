require_relative '../../lib/mince/config'

describe Mince::Config do
  it 'has a default database name' do
    described_class.database_name.should == 'mince'
  end

  context 'when running multi threaded tests' do
    before do
      ENV['TEST_ENV_NUMBER'] = '3'
      described_class.database_name = 'test'
    end

    after do
      ENV['TEST_ENV_NUMBER'] = nil
    end

    it 'appends the test number to the database name' do
      described_class.database_name.should == 'test-3'
    end
  end

  context 'when specifying a custom database name' do
    before do
      described_class.database_name = 'custom'
    end

    it 'uses the custom database name' do
      described_class.database_name.should == 'custom'
    end
  end
end
