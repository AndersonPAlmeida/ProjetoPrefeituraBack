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

class CreateJoinTableServiceTypesServicePlaces < ActiveRecord::Migration[5.0]
  def change
    create_join_table :service_types, :service_places do |t|
      t.boolean :active, null: false, default: true
      t.index [:service_type_id, :service_place_id], name: "idx_service_type_service_place"
      t.index [:service_place_id, :service_type_id], name: "idx_service_place_service_type"
    end
  end
end
