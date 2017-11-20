class CreateResources < ActiveRecord::Migration[5.0]
  def change
    create_table :resources do |t|
      t.integer :resource_types_id, foreign_key: true, null: false
      t.integer :service_place_id, foreign_key: true, null: false
      t.integer :professional_responsible_id, foreign_key: true
      t.float :minimum_schedule_time, null: false
      t.float :maximum_schedule_time, null: false
      t.integer :active, null: false
      t.string :brand
      t.string :model
      t.string :label
      t.string :note
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false

      t.timestamps
    end
  end
end
