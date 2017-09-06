class AddCityRefToCityHall < ActiveRecord::Migration[5.0]
  def change
    add_reference :city_halls, :city, index: true, null: false
  end
end
