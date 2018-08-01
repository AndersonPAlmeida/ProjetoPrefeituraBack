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

class ResourceType < ApplicationRecord
    include Searchable
    
    has_many :resource
    belongs_to :city_hall


    validates_presence_of :city_hall_id,
                          :name,
                          :mobile


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
            sortable = ["city_hall_id","name", "active", "mobile", "description"]
            filter = {"name" => "name_cont", "description" => "description_cont", 
                    "city_hall_id" => "city_hall_id_eq", "s" => "s"}

        when "adm_prefeitura"
            sortable = ["name", "description", "active", "mobile"]
            filter = {"name" => "name_cont", "description" => "description_cont", "s" => "s"}

        when "adm_local"
            sortable = ["name", "description", "active", "mobile"]
            filter = {"name" => "name_cont", "description" => "description_cont", "s" => "s"}
        end

        return filter_search_params(params, filter, sortable) 
    end
end
