class AddCityRefToServicePlaces < ActiveRecord::Migration[5.0]
  def change
    add_reference :service_places, :city, index: true, null: false
  end
end
