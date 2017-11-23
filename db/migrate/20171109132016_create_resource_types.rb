class CreateResourceTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :resource_types do |t|
      t.integer :city_hall_id,  foreign_key: true, null: false
      t.string :name, null: false
      t.integer :active, null: false
      t.string :mobile, null: false
      t.string :description
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false

      t.timestamps
    end
  end
end
