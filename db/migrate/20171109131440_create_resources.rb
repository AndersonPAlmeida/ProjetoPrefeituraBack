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

class CreateResources < ActiveRecord::Migration[5.0]
  def change
    create_table :resources do |t|
      t.integer :resource_types_id, foreign_key: true, null: false
      t.integer :service_place_id, foreign_key: true, null: false
      t.integer :professional_responsible_id, foreign_key: true
      t.float :minimum_schedule_time, null: false
      t.float :maximum_schedule_time, null: false
      t.integer :active, null: false
      t.string :brand
      t.string :model
      t.string :label
      t.string :note
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false

      t.timestamps
    end
  end
end
