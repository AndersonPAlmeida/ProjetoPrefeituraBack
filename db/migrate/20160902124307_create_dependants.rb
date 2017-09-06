class CreateDependants < ActiveRecord::Migration[5.0]
  def change
    create_table :dependants do |t|
      t.datetime :deactivated
      t.references :citizen, index: true, null: false
      t.timestamps
    end
  end
end
