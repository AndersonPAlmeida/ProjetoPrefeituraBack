class SectorSerializer < ActiveModel::Serializer
  belongs_to :city_hall
  attributes :id, :name, :absence_max, :blocking_days, :cancel_limit, :description, :name
end
