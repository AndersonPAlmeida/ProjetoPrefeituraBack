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

class CreateShifts < ActiveRecord::Migration[5.0]
  def change
    create_table :shifts do |t|
      t.references :service_place, index: true, null: false
      t.references :service_type, index: true, null: false
      t.integer :next_shift_id
      t.integer :professional_performer_id
      t.integer :professional_responsible_id
      t.datetime :execution_start_time
      t.datetime :execution_end_time
      t.integer :service_amount
      t.text :notes
      t.timestamps
    end
  end
end
