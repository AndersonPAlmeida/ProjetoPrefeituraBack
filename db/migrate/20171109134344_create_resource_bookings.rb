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

class CreateResourceBookings < ActiveRecord::Migration[5.0]
  def change
    create_table :resource_bookings do |t|
      t.integer :service_place_id, foreign_key: true, null: false
      t.integer :resource_shift_id, foreign_key: true, null: false
      t.integer :situation_id, foreign_key: true, null: false
      t.integer :citizen_id, foreign_key: true, null: false
      t.integer :active, null: false
      t.string :booking_reason, null: false
      t.datetime :booking_start_time, null: false
      t.datetime :booking_end_time, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.string :status, null: false

      t.timestamps
    end
  end
end
