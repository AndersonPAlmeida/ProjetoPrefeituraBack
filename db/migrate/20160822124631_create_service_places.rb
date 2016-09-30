class CreateServicePlaces < ActiveRecord::Migration[5.0]
  def change
    create_table :service_places do |t|
      t.string :name, :null => false
      t.string :cep, :limit => 10
      t.string :neighborhood, :null => false
      t.string :address_street, :null => false
      t.string :address_number, :null => false, :limit => 10
      t.string :address_complement
      t.string :phone1, :limit => 13
      t.string :phone2, :limit => 13
      t.string :email
      t.string :url
      t.boolean :active, :null => false, :default => true
      t.timestamps
    end
  end
end
