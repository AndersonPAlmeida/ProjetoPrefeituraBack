class DeviseTokenAuthCreateAccounts < ActiveRecord::Migration
  def change
    create_table(:accounts) do |t|
      ## Database authenticatable
      t.string :encrypted_password, :null => false, :default => ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, :default => 0, :null => false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      t.string :provider, :null => false, :default => "cpf"
      t.string :uid, :null => false, :default => ""

      ## Tokens
      t.json :tokens

      t.timestamps
    end

    add_index :accounts, :uid,                  :unique => true
    add_index :accounts, :reset_password_token, :unique => true
  end
end