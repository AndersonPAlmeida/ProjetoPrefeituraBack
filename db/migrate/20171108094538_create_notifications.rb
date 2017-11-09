class CreateNotifications < ActiveRecord::Migration[5.0]
  
  def change
    create_table :notifications do |t|
      t.integer :accounts_id, foreign_key: true, null: false
      t.integer :schedule_id, foreign_key: true 
      t.integer :resource_schedule_id, foreign_key: true 
      t.datetime :reminder_time
      t.integer :read
      t.string :content
      t.datetime :created_at
      t.datetime :updated_at

      t.timestamps
    end
  end
end
