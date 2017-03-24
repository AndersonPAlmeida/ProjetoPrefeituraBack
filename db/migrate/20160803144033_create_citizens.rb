class CreateCitizens < ActiveRecord::Migration[5.0]
  def change
    create_table :citizens do |t|
      t.date :birth_date, null: false
      t.string :name, null: false
      t.string :rg, null: false
      t.string :address_complement
      t.string :address_number
      t.string :address_street
      t.string :cep
      t.string :cpf
      t.string :email
      t.string :neighborhood
      t.string :note
      t.string :pcd
      t.string :phone1
      t.string :phone2
      t.timestamps
    end
  end
end
