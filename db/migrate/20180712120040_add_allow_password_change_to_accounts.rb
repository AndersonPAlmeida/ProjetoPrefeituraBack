class AddAllowPasswordChangeToAccounts < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :allow_password_change, :boolean, default: false
  end
end
