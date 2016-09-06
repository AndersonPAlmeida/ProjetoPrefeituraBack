class CreateBlocks < ActiveRecord::Migration[5.0]
  def change
    create_table :blocks do |t|
      t.references :account ,index:true, null: false
      t.references :citizen, index: true, null: false
      t.references :dependant, index: true
      t.date :block_begin
      t.date :block_end
    end
  end
end
