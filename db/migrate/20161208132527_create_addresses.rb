class CreateAddresses < ActiveRecord::Migration[5.0]
  def change
    create_table :addresses do |t|
      t.string :zipcode
      t.string :address
      t.string :neighborhood
      t.string :complement
      t.string :complement2

      t.timestamps
    end
  end
end
