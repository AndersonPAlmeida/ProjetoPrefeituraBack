class AddCityHallToServicePlaces < ActiveRecord::Migration[5.0]
  def change
    add_reference :service_places, :city_hall, index: true, null: false
  end
end
