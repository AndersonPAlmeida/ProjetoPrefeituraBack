class AddCityToCitizens < ActiveRecord::Migration[5.0]
  def change
    add_reference :citizens, :city, index: true
  end
end
