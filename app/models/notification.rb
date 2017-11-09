class Notification < ApplicationRecord
    # belongs_to :account
    belongs_to :schedule, optional: true
    # TODO: belongs_to: resource_booking

    validates_presence_of :accounts_id, 
                          :reminder_time,
                          :read,
                          :content

    

end
