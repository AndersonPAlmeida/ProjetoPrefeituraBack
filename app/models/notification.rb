class Notification < ApplicationRecord
    # belongs_to :account
    belongs_to :schedule, optional: true
    # TODO: belongs_to: resource_booking

    validates_presence_of :account_id, 
                          :reminder_time,
                          :read,
                          :content

    def get_notification_id
    end
    

end
