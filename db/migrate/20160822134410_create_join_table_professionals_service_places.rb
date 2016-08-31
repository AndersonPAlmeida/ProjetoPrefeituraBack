class CreateJoinTableProfessionalsServicePlaces < ActiveRecord::Migration[5.0]
  def change
    create_join_table :professionals, :service_places do |t|
      t.string :role, :null => false
      t.boolean :active, :null => false, :default => true
      # t.index [:professional_id, :service_place_id]
      # t.index [:service_place_id, :professional_id]
    end
  end
end
