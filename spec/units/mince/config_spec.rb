require_relative '../../../lib/mince/config'

describe Mince::Config do
  it 'can be assigned an mince interface' do
    interface = mock
    described_class.interface = interface

    described_class.interface.should == interface
  end
end
