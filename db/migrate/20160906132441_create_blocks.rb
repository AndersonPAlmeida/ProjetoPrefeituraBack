class CreateBlocks < ActiveRecord::Migration[5.0]
  def change
    create_table :blocks do |t|
      t.references :citizen ,index: true, foreign_key: true, null: false
      t.references :dependant, index: true, foreign_key: true
      t.date :block_begin
      t.date :block_end
    end
  end
end
