class AddStateRefToCity < ActiveRecord::Migration[5.0]
  def change
    add_reference :cities, :state, index: true, null: false
  end
end
