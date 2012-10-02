require 'hashy_db'

require_relative '../../../lib/mince/shared_examples/interface_example'

describe 'The shared example for a mince interface' do
  before do
    Mince::Config.interface = Mince::HashyDb::Interface
  end

  it_behaves_like 'a mince interface'
end
