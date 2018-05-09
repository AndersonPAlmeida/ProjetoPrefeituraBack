class CreateCitizenUploads < ActiveRecord::Migration[5.0]
  def change
    create_table :citizen_uploads do |t|
      t.references :citizen, foreign_key: true
      t.integer :amount
      t.float :progress

      t.timestamps
    end
  end
end
