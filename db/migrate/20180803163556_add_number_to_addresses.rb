class AddNumberToAddresses < ActiveRecord::Migration[5.0]
  def change
    add_column :addresses, :number, :integer
  end
end
