class CreateSchedules < ActiveRecord::Migration[5.0]
  def change
    create_table :schedules do |t|
      t.references :shift, index: true, null: false
      t.references :situation, index: true, null: false
      t.references :service_place, index: true, null: false
      t.references :account, index: true
      t.integer :citizen_ajax_id, null: false
      t.integer :professional_ajax_id, null: false
      t.integer :reminder_read, null: false
      t.datetime :service_start_time, null: false
      t.datetime :service_end_time, null: false
      t.string :note
      t.integer :reminder_email_sent
      t.integer :remainder_time
      t.timestamps
    end
  end
end
