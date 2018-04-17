class AddColumnsToCitizenUpload < ActiveRecord::Migration[5.0]
  def change
    add_column :citizen_uploads, :status, :integer
  end
end
