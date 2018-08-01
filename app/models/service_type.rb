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

class ServiceType < ApplicationRecord
  include Searchable

  # Associations #
  belongs_to :sector
  has_and_belongs_to_many :service_places

  # Validations #
  validates_presence_of :description
  validates_inclusion_of :active, in: [true, false]

  # Scopes #
  scope :all_active, -> {
    where(active: true)
  }

  scope :local_city_hall, -> (city_hall_id) { 
    where(sectors: {city_hall_id: city_hall_id}).includes(:sector) 
  }

  # Delegations #
  delegate :name, to: :sector, prefix: true
  delegate :city_hall_id, to: :sector, prefix: true
  delegate :id, to: :service_places, prefix: true
  delegate :city_hall_name, to: :sector
  delegate :city_hall_id, to: :sector


  # Returns json response to index service_types 
  # @return [Json] response
  def self.index_response
    self.all.as_json(only: [
      :id, :description, :active
    ], methods: %w(sector_name city_hall_name))
  end


  # @return [Json] detailed service_type's data
  def complete_info_response
    return self.as_json(only: [
      :id, :description, :active, 
      :sector_id, :created_at, :updated_at
    ], methods: %w(city_hall_name city_hall_id))
  end


  # Response used to fill the list of service_types in the scheduling process,
  # consists of all the service_type from a given sector
  # @param sector_id [String] the id of the specified sector
  # @return [Json] reponse with list of service_types
  def self.schedule_response(sector_id)
    response = ServiceType.where(sector_id: sector_id, active: true)
      .as_json(only: [:id, :active, :description])

    # Add number of available schedules for each service_type
    for i in response 
      i["schedules"] = Schedule.where(shifts: {service_type_id: i["id"]})
        .includes(:shift)
        .where(situation_id: Situation.disponivel)
        .count
    end

    return response
  end


  # @params params [ActionController::Parameters] Parameters for searching
  # @params npage [String] number of page to be returned
  # @params permission [String] Permission of current user
  # @return [ActiveRecords] filtered service_types
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
      sortable = ["description", "active", "sector_name", "sector_city_hall_name"]
      filter = {"description" => "description_cont", "active" => "active_eq", 
                "city_hall_id" => "sector_city_hall_id_eq", "s" => "s"}

    when "adm_prefeitura"
      sortable = ["description", "active", "sector_name"]
      filter = {"description" => "description_cont", "active" => "active_eq", "s" => "s"}

    end

    return filter_search_params(params, filter, sortable) 
  end
end
