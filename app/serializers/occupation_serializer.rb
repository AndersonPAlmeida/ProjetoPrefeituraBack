class OccupationSerializer < ActiveModel::Serializer
  attributes :id, :description, :name, :active
  has_one :city_hall
end
