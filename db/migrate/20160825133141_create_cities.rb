class CreateCities < ActiveRecord::Migration[5.0]
  def change
    create_table :cities do |t|
      t.string :ibge_code, null: false
      t.string :name, null: false
      t.timestamps
    end
  end
end
