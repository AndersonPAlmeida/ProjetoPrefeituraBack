class Sector < ApplicationRecord
  include Searchable

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

  scope :all_active, -> { where(active: true) }

  scope :local, ->(city_id) { 
    where(city_halls: {city_id: city_id}).includes(:city_hall)
  }

  # In the scheduling process, the first request should return every available
  # local sector and for each of them show if it is blocked or not
  #
  # @param citizen [Citizen] the citizen which the schedule will be scheduled for
  # @return [Json] json response to schedule processing with the available sectors
  def self.schedule_response(citizen)

    # Array with ids of the sectors which the citizen is blocked
    blocks = Block.where(citizen_id: citizen.id).pluck(:sector_id)

    # Every active local sector as Json
    response = Sector.all_active.local(citizen.city_id).as_json(only: [
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

  # @params params [ActionController::Parameters] Parameters for searching
  # @params npage [String] number of page to be returned
  # @return [ActiveRecords] filtered sectors
  def self.filter(params, npage)
    return search(search_params(params), npage)
  end

  private

  # Translates incoming search parameters to ransack patterns
  # @params params [ActionController::Parameters] Parameters for searching
  # @return [Hash] filtered and translated parameters
  def self.search_params(params)
    sortable = ["name", "description", "active", "schedules_by_sector"]
    filter = {"name" => "name_cont", "description" => "description_cont", "s" => "s"}

    return filter_search_params(params, filter, sortable) 
  end
end
