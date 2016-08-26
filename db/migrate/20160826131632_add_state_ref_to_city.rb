class AddStateRefToCity < ActiveRecord::Migration[5.0]
  def change
    add_reference :cities, :state, foreign_key: true
  end
end
