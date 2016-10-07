class AddResponsibleToCitizens < ActiveRecord::Migration[5.0]
  def change
    add_column :citizens, :responsible_id, :integer
  end
end
