class CreateSectors < ActiveRecord::Migration[5.0]
  def change
    create_table :sectors do |t|
      t.references :city_hall, index: true, null: false
      t.boolean :active
      t.integer :absence_max
      t.integer :blocking_days
      t.integer :cancel_limit
      t.text :description
      t.string :name
      t.integer :shedules_by_sector
      t.timestamps
    end
  end
end
