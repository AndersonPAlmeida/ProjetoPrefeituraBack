class CreateJoinTableServiceTypesServicePlaces < ActiveRecord::Migration[5.0]
  def change
    create_join_table :service_types, :service_places do |t|
      # t.index [:service_type_id, :service_place_id]
      # t.index [:service_place_id, :service_type_id]
    end
  end
end
