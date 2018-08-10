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

class CreateCityHalls < ActiveRecord::Migration[5.0]
  def change
    create_table :city_halls do |t|
      t.integer :city_id, null: false
      t.boolean :active, null: false
      t.string :address_number, null: false, limit: 10
      t.string :address_street, null: false
      t.text :block_text, null: false
      t.string :cep, limit: 10, null: false
      t.boolean :citizen_access, null: false, default: true
      t.boolean :citizen_register, null: false, default: true
      t.string :name, null: false
      t.string :neighborhood, null: false
      t.integer :schedule_period, null: false, default: 90
      t.string :address_complement
      t.text :description
      t.string :email
      t.string :logo_content_type
      t.string :logo_file_name
      t.integer :logo_file_size
      t.date :logo_updated_at
      t.string :phone1, limit: 14
      t.string :phone2, limit: 14
      t.string :support_email
      t.boolean :show_professional
      t.string :url

      t.timestamps
    end
  end
end
