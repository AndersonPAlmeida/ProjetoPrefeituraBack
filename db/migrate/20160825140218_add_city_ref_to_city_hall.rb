class AddCityRefToCityHall < ActiveRecord::Migration[5.0]
  def change
    add_reference :city_halls, :city, foreign_key: true
  end
end
