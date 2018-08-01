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

class CreateCitizens < ActiveRecord::Migration[5.0]
  def change
    create_table :citizens do |t|
      t.date :birth_date, null: false
      t.string :name, null: false
      t.string :rg
      t.string :address_complement
      t.string :address_number
      t.string :address_street
      t.string :cep
      t.string :cpf
      t.string :email
      t.string :neighborhood
      t.string :note
      t.string :pcd
      t.string :phone1
      t.string :phone2
      t.timestamps
    end
  end
end
