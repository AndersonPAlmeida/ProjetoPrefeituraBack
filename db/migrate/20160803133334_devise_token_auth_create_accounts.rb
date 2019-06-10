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

class DeviseTokenAuthCreateAccounts < ActiveRecord::Migration[5.0]
  def change
    create_table(:accounts) do |t|
      ## Database authenticatable
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      t.string :provider, null: false, default: "cpf"
      t.string :uid, null: false, default: ""
      t.string :email

      ## Tokens
      t.json :tokens

      t.timestamps
    end

    reversible do |direction|
      direction.up do
        Account.find_each do |account|
          account.uid = account.email
          account.tokens = nil
          account.save!
        end
      end
    end

    add_index :accounts, :uid,                  unique: true
    add_index :accounts, :reset_password_token, unique: true
  end
end
