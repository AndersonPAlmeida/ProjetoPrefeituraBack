class AddCityToCitizens < ActiveRecord::Migration[5.0]
  def change
    add_reference :citizens, :city, foreign_key: true, index: true
  end
end
