class ServiceTypeSerializer < ActiveModel::Serializer
  attributes :id, 
    :active, 
    :description

  belongs_to :sector
end
