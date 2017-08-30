class AddIdToProfessionalsServicePlace < ActiveRecord::Migration[5.0]
  def change
    add_column :professionals_service_places, :id, :primary_key
  end
end
