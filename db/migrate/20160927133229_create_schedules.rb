class CreateSchedules < ActiveRecord::Migration[5.0]
  def change
    create_table :schedules do |t|
      t.references :shift, foreign_key: true, index: true, null: false
      t.references :situation, foreign_key: true, index: true, null: false
      t.references :service_place, foreign_key: true, index: true, null: false
      t.references :citizen, foreign_key: true, index: true
      t.integer :citizen_ajax_read, null: false
      t.integer :professional_ajax_read, null: false
      t.integer :reminder_read, null: false
      t.datetime :service_start_time, null: false
      t.datetime :service_end_time, null: false
      t.datetime :reminder_time
      t.string :note
      t.integer :reminder_email_sent
      t.timestamps
    end
  end
end
