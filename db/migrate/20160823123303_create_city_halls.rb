class CreateCityHalls < ActiveRecord::Migration[5.0]
  def change
    create_table :city_halls do |t|
      t.integers :city_id
      t.boolean :active
      t.string :address_number, null: false, limit: 10
      t.string :address_street, null: false
      t.text :block_text, null: false
      t.string :cep, limit: 10, null: false
      t.boolean :citizen_access, null: false, default: true
      t.boolean :citizen_register, null: false, default: true
      t.string :name, null: false
      t.string :neighborhood, null: false
      t.integer :previous_notice, null: false, default: 48
      t.integer :schedule_period, null: false, default: 90
      t.string :address_complement
      t.text :description
      t.string :email
      t.string :logo_content_type
      t.string :logo_file_name
      t.integer :logo_file_size
      t.date :logo_updated_at
      t.string :phone1, limit: 14
      t.string :phone2, limit: 14
      t.string :support_email
      t.boolean :show_professional
      t.string :url

      t.timestamps
    end
  end
end
