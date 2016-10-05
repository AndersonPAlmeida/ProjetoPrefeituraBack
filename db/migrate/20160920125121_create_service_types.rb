class CreateServiceTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :service_types do |t|
      t.references :sector, index: true, null: false
      t.boolean :active 
      t.text :description
      t.timestamps
    end
  end
end
