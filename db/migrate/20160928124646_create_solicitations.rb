class CreateSolicitations < ActiveRecord::Migration[5.0]
  def change
    create_table :solicitations do |t|
      t.references :city, foreign_key: true, index: true
      t.string :name, null: false
      t.string :cpf, null: false
      t.string :email, null: false
      t.string :cep
      t.string :phone
      t.boolean :sent

      t.timestamps
    end
  end
end
