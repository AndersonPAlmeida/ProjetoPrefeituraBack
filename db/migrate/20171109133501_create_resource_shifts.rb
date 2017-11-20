class CreateResourceShifts < ActiveRecord::Migration[5.0]
  def change
    create_table :resource_shifts do |t|
      t.integer :resource_id, foreign_key: true, null: false
      t.integer :professional_responsible_id, foreign_key: true, null: false
      t.integer :next_shift_id, foreign_key: true, null: false
      t.integer :active, null: false
      t.integer :borrowed, null: false
      t.datetime :execution_start_time, null: false
      t.datetime :execution_end_time, null: false
      t.string :notes
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false

      t.timestamps
    end
  end
end
