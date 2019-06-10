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

class CreateSchedules < ActiveRecord::Migration[5.0]
  def change
    create_table :schedules do |t|
      t.references :shift, index: true, null: false
      t.references :situation, index: true, null: false
      t.references :service_place, index: true, null: false
      t.references :citizen, index: true
      t.integer :citizen_ajax_read, null: false
      t.integer :professional_ajax_read, null: false
      t.integer :reminder_read, null: false
      t.datetime :service_start_time, null: false
      t.datetime :service_end_time, null: false
      t.datetime :reminder_time
      t.string :note
      t.integer :reminder_email_sent
      t.timestamps
    end
  end
end
