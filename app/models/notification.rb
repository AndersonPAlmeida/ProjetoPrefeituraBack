class Notification < ApplicationRecord
  # belongs_to :account
  belongs_to :schedule, optional: true
  belongs_to :resource_booking, optional: true

  validates_presence_of :account_id, 
    :reminder_time,
    :content

  validates_inclusion_of :read, in: [true, false]
end
