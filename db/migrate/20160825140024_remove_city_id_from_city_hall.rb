class RemoveCityIdFromCityHall < ActiveRecord::Migration[5.0]
  def change
    remove_column :city_halls, :city_id, :integer
  end
end
