require_relative '../../../lib/mince/data_model'

class GuitarDataModel
  include Mince::DataModel

  data_collection :guitars
  data_fields :brand, :price, :type, :color
end

