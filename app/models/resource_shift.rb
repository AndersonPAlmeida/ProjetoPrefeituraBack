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

class ResourceShift < ApplicationRecord
    include Searchable

    has_many :resource_booking
    has_one :professionals_service_place
    has_one :resource
    has_many :resource_shift

    validates_presence_of :resource_id,
                          :professional_responsible_id,
                          :execution_start_time,
                          :execution_end_time,
                          :borrowed,
                          :active


    def self.filter(params, npage, permission)
        return search(search_params(params, permission), npage)
    end

    ransacker :date_start do
      Arel.sql("date(\"resource_shifts\".\"execution_start_time\")")
    end
    ransacker :date_end do
      Arel.sql("date(\"resource_shifts\".\"execution_end_time\")")
    end

    private

    # Translates incoming search parameters to ransack patterns
    # @params params [ActionController::Parameters] Parameters for searching
    # @params permission [String] Permission of current user
    # @return [Hash] filtered and translated parameters
    def self.search_params(params, permission)

        sortable = ["resource_id",
                    "professional_responsible_id",
                    "next_shift_id",
                    "active",
                    "borrowed",
                    "execution_start_time",
                    "execution_end_time",
                    "notes",
                    "created_at",
                    "updated_at"
                    ]
        filter = {
                    "resource_id" => "resource_id_eq",
                    "professional_responsible_id" => "professional_responsible_id_eq",
                    "borrowed" => "borrowed_eq",
                    "execution_start_time" => "date_start_eq" ,
                    "execution_end_time" => "date_end_eq",
                    "notes" => "notes_cont",
                    "s" => "s" 
                 }

        return filter_search_params(params, filter, sortable) 
    end

end
