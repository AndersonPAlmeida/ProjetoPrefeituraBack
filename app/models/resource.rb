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

class Resource < ApplicationRecord    
    include Searchable
    
    belongs_to :service_place
    has_one :resource_type
    has_many :resource_shift

    validates_presence_of :resource_types_id, 
                          :service_place_id,
                          :minimum_schedule_time,
                          :maximum_schedule_time,
                          :active


    def self.filter(params, npage, permission)
        return search(search_params(params, permission), npage)
    end

    private

    # Translates incoming search parameters to ransack patterns
    # @params params [ActionController::Parameters] Parameters for searching
    # @params permission [String] Permission of current user
    # @return [Hash] filtered and translated parameters
    def self.search_params(params, permission)


        sortable = ["resource_types_id",
                    "service_place_id",
                    "professional_responsible_id",
                    "minimum_schedule_time",
                    "maximum_schedule_time",
                    "active",
                    "brand",
                    "model",
                    "label",
                    "note"
                    ]
        filter = {
                    "service_place_id" => "service_place_id_eq",
                    "professional_responsible_id" => "professional_responsible_id_eq",
                    "brand" => "brand_cont",
                    "model" => "model_cont",
                    "label" => "label_cont",
                    "note" => "note_cont", 
                    "s" => "s" 
                    }

        return filter_search_params(params, filter, sortable) 
    end

end
