class Notification < ApplicationRecord
    # belongs_to :account
    belongs_to :schedule, optional: true
    belongs_to :resource_booking, optional: true

    validates_presence_of :accounts_id, 
                          :reminder_time,
                          :read,
                          :content

    

end
