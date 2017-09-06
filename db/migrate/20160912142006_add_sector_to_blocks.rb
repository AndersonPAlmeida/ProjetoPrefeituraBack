class AddSectorToBlocks < ActiveRecord::Migration[5.0]
  def change
    add_reference :blocks, :sector, index: true, null: false
  end
end
