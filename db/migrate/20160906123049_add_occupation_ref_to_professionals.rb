class AddOccupationRefToProfessionals < ActiveRecord::Migration[5.0]
  def change
    add_reference :professionals, :occupation, foreign_key: true
  end
end
