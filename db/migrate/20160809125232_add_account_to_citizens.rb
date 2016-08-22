class AddAccountToCitizens < ActiveRecord::Migration[5.0]
  def change
    add_reference :citizens, :account, foreign_key: true
  end
end
