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

class CreateNotifications < ActiveRecord::Migration[5.0]
  
  def change
    create_table :notifications do |t|
      t.integer :account_id, foreign_key: true, null: false
      t.integer :schedule_id, foreign_key: true 
      t.integer :resource_schedule_id, foreign_key: true 
      t.boolean :read
      t.string :content
      t.datetime :reminder_time
      t.integer :reminder_email_sent
      t.string :reminder_email
      t.datetime :created_at
      t.datetime :updated_at

      t.timestamps
    end
  end
end
