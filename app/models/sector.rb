# This file is part of Agendador.
#
# Agendador is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Agendador is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Agendador.  If not, see <https://www.gnu.org/licenses/>.

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
    :schedules_by_sector,
    :previous_notice

  validates_inclusion_of :active, in: [true, false]

  validates_numericality_of :previous_notice, greater_than: 0,
    less_than_or_equal_to: 2000000000

  # Scopes #
  scope :all_active, -> { 
    where(active: true) 
  }

  scope :local, ->(city_id) { 
    where(city_halls: {city_id: city_id}).includes(:city_hall)
  }


  # Delegations #
  delegate :name, to: :city_hall, prefix: true

  
  # Returns json response to index schedules 
  # @return [Json] response
  def self.index_response
    return self.all.as_json(only: [
      :id, :name, :active, :schedules_by_sector, 
      :description],
      methods: %w(city_hall_name)
    )
  end


  # @return [Json] detailed sector's data
  def complete_info_response
    return self.as_json(only: [
      :id, :absence_max, :active, 
      :blocking_days, :cancel_limit, :description, 
      :name, :previous_notice, :schedules_by_sector, 
      :city_hall_id
    ])
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
  # @params permission [String] Permission of current user
  # @return [ActiveRecords] filtered sectors
  def self.filter(params, npage, permission)
    return search(search_params(params, permission), npage)
  end


  private

  # Translates incoming search parameters to ransack patterns
  # @params params [ActionController::Parameters] Parameters for searching
  # @params permission [String] Permission of current user
  # @return [Hash] filtered and translated parameters
  def self.search_params(params, permission)

    case permission
    when "adm_c3sl"
      sortable = ["name", "description", "active", "schedules_by_sector", "city_hall_name"]
      filter = {"name" => "name_cont", "description" => "description_cont", 
                "city_hall_id" => "city_hall_id_eq", "s" => "s"}

    when "adm_prefeitura"
      sortable = ["name", "description", "active", "schedules_by_sector"]
      filter = {"name" => "name_cont", "description" => "description_cont", "s" => "s"}
    end

    return filter_search_params(params, filter, sortable) 
  end
end
