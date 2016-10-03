class CreateSolicitations < ActiveRecord::Migration[5.0]
  def change
    create_table :solicitations do |t|
      t.references :city, foreign_key: true
      t.string :name
      t.string :cpf
      t.string :email
      t.string :cep
      t.string :phone
      t.boolean :sent

      t.timestamps
    end
  end
end
