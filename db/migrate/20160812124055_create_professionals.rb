class CreateProfessionals < ActiveRecord::Migration[5.0]
  def change
    create_table :professionals do |t|
      t.string :registration
      t.boolean :active, :null => false, :default => true
      t.timestamps
      t.references :citizen
    end
  end
end
