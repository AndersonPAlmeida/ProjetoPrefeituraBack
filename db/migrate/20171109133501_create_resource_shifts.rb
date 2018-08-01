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

class CreateResourceShifts < ActiveRecord::Migration[5.0]
  def change
    create_table :resource_shifts do |t|
      t.integer :resource_id, foreign_key: true, null: false
      t.integer :professional_responsible_id, foreign_key: true, null: false
      t.integer :next_shift_id, foreign_key: true
      t.integer :active, null: false
      t.integer :borrowed, null: false
      t.datetime :execution_start_time, null: false
      t.datetime :execution_end_time, null: false
      t.string :notes
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false

      t.timestamps
    end
  end
end
