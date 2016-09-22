class ServiceTypeSerializer < ActiveModel::Serializer
  belongs_to :sector
  attributes :id, :active, :description
end
