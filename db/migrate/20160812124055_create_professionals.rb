class CreateProfessionals < ActiveRecord::Migration[5.0]
  def change
    create_table :professionals do |t|
      t.string :registration
      t.boolean :active, null: false, default: true
      t.timestamps
      t.references :account, foreign_key: true, index: true
    end
  end
end
