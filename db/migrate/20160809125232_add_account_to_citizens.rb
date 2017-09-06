class AddAccountToCitizens < ActiveRecord::Migration[5.0]
  def change
    add_reference :citizens, :account, index: true
  end
end
