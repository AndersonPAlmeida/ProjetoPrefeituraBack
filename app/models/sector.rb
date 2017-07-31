class Sector < ApplicationRecord

  # Associations #
  has_many   :blocks
  belongs_to :city_hall

  # Validations #
  validates_presence_of :absence_max,
    :blocking_days,
    :cancel_limit,
    :description,
    :name,
    :schedules_by_sector

  validates_inclusion_of :active, in: [true, false]

  # @return all active sectors
  def self.all_active
    Sector.where(active: true)
  end

  # @return all active sectors which city_hall belongs to city_id
  def self.all_active_local(city_id)
    city_hall = CityHall.find_by(city_id: city_id)
    Sector.all_active.where(city_hall_id: city_hall.id)
  end

  def self.schedule_response(citizen)
    blocks = Block.where(account_id: citizen.account_id).pluck(:sector_id)

    response = Sector.all_active_local(citizen.city_id).as_json(only: [
      :id, :absence_max, :blocking_days, :cancel_limit, 
      :description, :name, :schedule_by_sector
    ])

    for i in response
      if blocks.include? i["id"]
        i["blocked"] = "true"
      else
        i["blocked"] = "false"
      end
    end

    return response
  end
end
