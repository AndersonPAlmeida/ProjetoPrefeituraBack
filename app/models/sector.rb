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

  # @param city_id [Integer] sectors returned are registered with this given city_id
  # @return all active sectors which city_hall belongs to city_id
  def self.local_active(city_id)
    city_hall = CityHall.find_by(city_id: city_id)
    Sector.all_active.where(city_hall_id: city_hall.id)
  end

  # In the scheduling process, the first request should return every available
  # local sector and for each of them show if it is blocked or not
  #
  # @param citizen [Citizen] the citizen which the schedule will be scheduled for
  # @return [Json] json response to schedule processing with the available sectors
  def self.schedule_response(citizen)
    # Array with ids of the sectors which the citizen is blocked
    blocks = Block.where(citizen_id: citizen.id).pluck(:sector_id)

    # Every active local sector as Json
    response = Sector.local_active(citizen.city_id).as_json(only: [
      :id, :absence_max, :blocking_days, :cancel_limit, 
      :description, :name, :schedule_by_sector
    ])

    for i in response
      # If the array with the blocked sectors contains the current sector...
      if blocks.include? i["id"]
        i["blocked"] = "true"
      else
        i["blocked"] = "false"
      end
    end

    return response
  end

  # Used to return information required to fill forms in front-end
  #
  # @param user [Array] current_user (session variable)
  # @return [Json] list of reachable sectors
  def self.form_data(user)
    @citizen = user[0]
    @permission = user[1]

    response = Sector.local_active(@citizen.city_id)
      .as_json(only: [:name, :id])

    return response
  end
end
