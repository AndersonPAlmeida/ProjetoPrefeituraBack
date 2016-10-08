class AddStateRefToCity < ActiveRecord::Migration[5.0]
  def change
    add_reference :cities, :state, foreign_key: true, index: true, null: false
  end
end
