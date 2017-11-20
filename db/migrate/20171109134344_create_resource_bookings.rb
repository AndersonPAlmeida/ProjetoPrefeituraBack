class CreateResourceBookings < ActiveRecord::Migration[5.0]
  def change
    create_table :resource_bookings do |t|
      t.integer :address_id, foreign_key: true, null: false
      t.integer :resource_shift_id, foreign_key: true, null: false
      t.integer :situation_id, foreign_key: true, null: false
      t.integer :citizen_id, foreign_key: true, null: false
      t.integer :active, null: false
      t.string :booking_reason, null: false
      t.datetime :booking_start_time, null: false
      t.datetime :booking_end_time, null: false
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false

      t.timestamps
    end
  end
end
