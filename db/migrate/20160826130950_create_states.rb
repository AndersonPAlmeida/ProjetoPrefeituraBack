class CreateStates < ActiveRecord::Migration[5.0]
  def change
    create_table :states do |t|
      t.string :abbreviation, null: false, limit: 2
      t.string :ibge_code, null: false
      t.string :name, null: false

      t.timestamps
    end
  end
end
