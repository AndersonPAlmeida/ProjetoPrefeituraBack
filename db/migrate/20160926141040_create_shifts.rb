class CreateShifts < ActiveRecord::Migration[5.0]
  def change
    create_table :shifts do |t|
      t.references :service_place, index: true, null: false
      t.references :service_type, index: true, null: false
      t.integer :next_shift_id
      t.integer :professional_performer_id
      t.integer :professional_responsible_id
      t.datetime :execution_start_time
      t.datetime :execution_end_time
      t.integer :service_amount
      t.text :notes
      t.timestamps
    end
  end
end
