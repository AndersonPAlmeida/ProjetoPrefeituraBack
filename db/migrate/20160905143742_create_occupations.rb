class CreateOccupations < ActiveRecord::Migration[5.0]
  def change
    create_table :occupations do |t|
      t.string :description
      t.string :name
      t.boolean :active
      t.references :city_hall, foreign_key: true, index: true, null: false

      t.timestamps
    end
  end
end
