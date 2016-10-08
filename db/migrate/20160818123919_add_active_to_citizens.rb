class AddActiveToCitizens < ActiveRecord::Migration[5.0]
  def change
    add_column :citizens, :active, :boolean, null: false
  end
end
