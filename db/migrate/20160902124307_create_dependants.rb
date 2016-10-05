class CreateDependants < ActiveRecord::Migration[5.0]
  def change
    create_table :dependants do |t|
      t.boolean :active, :null => false, :default => true
      t.datetime :deactivated
      t.references :citizen, index: true
      t.timestamps
    end
  end
end
