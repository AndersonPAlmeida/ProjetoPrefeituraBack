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

class CreateSectors < ActiveRecord::Migration[5.0]
  def change
    create_table :sectors do |t|
      t.references :city_hall, index: true, null: false
      t.boolean :active
      t.integer :absence_max
      t.integer :blocking_days
      t.integer :cancel_limit
      t.integer :previous_notice, null: false, default: 48
      t.text :description
      t.string :name
      t.integer :schedules_by_sector
      t.timestamps
    end
  end
end
