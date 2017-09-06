class AddDetailsToAddresses < ActiveRecord::Migration[5.0]
  def change
    add_reference :addresses, :city
    add_reference :addresses, :state
  end
end
