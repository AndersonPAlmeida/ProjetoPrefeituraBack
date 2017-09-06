class AddCityRefToServicePlaces < ActiveRecord::Migration[5.0]
  def change
    add_reference :service_places, :city
  end
end
