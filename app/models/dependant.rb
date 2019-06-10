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

class Dependant < ApplicationRecord
  include Searchable

  # Associations #
  belongs_to :citizen
  has_many   :blocks

  scope :all_active, -> { 
    where(citizens: { active: true }).includes(:citizen) 
  }


  # Returns json response to index dependants
  # @return [Json] response
  def self.index_response
    dependants_response = []

    self.all.each do |item|
      dependants_response.append(item.citizen.as_json(only: [
        :id, :name, :rg, :cpf, :birth_date
      ]))

      dependants_response[-1]["id"] = item.id
    end

    return dependants_response
  end

  # Used when the city, state and address are necessary (show)
  #
  # @return [Json] detailed dependant's data
  def complete_info_response
    return self.as_json(only: [:id, :deactivated])
      .merge({
        citizen: self.citizen.complete_info_response
      })
  end
  
  # @params params [ActionController::Parameters] Parameters for searching
  # @params npage [String] number of page to be returned
  # @return [ActiveRecords] filtered citizens 
  def self.filter(params, npage)
    return search(search_params(params), npage)
  end

  private

  # Translates incoming search parameters to ransack patterns
  # @params params [ActionController::Parameters] Parameters for searching
  # @return [Hash] filtered and translated parameters
  def self.search_params(params)
    sortable = ["citizen_name", "citizen_cpf", "citizen_birth_date"]
    filter = {"name" => "citizen_name_cont", "s" => "s"}

    return filter_search_params(params, filter, sortable) 
  end
end
