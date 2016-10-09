class OccupationSerializer < ActiveModel::Serializer
  attributes :id, 
             :active,
             :description, 
             :name

  has_one :city_hall
end
