class SectorSerializer < ActiveModel::Serializer
  attributes :id, 
    :absence_max, 
    :active,
    :blocking_days, 
    :cancel_limit, 
    :description,
    :name,
    :schedules_by_sector

  belongs_to :city_hall
end
