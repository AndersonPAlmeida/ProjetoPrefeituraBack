class AddDetailsToAddresses < ActiveRecord::Migration[5.0]
  def change
    add_reference :addresses, :city, foreign_key: true
    add_reference :addresses, :state, foreign_key: true
  end
end
