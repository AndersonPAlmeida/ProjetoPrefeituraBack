class ProfessionalsServicePlaceSerializer < ActiveModel::Serializer
  attributes :id, :professional_id, :service_place_id, :role, :active
  belongs_to :service_place
  belogns_to :professional
end
