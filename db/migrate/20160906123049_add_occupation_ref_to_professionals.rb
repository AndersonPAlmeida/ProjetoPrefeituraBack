class AddOccupationRefToProfessionals < ActiveRecord::Migration[5.0]
  def change
    add_reference :professionals, :occupation, foreign_key: true, index: true, null: false
  end
end
