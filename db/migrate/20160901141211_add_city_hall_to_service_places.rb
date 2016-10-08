class AddCityHallToServicePlaces < ActiveRecord::Migration[5.0]
  def change
    add_reference :service_places, :city_hall, foreign_key: true, index: true, null: false
  end
end
