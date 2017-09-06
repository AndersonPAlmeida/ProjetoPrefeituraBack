class AddOccupationRefToProfessionals < ActiveRecord::Migration[5.0]
  def change
    add_reference :professionals, :occupation, index: true, null: false
  end
end
