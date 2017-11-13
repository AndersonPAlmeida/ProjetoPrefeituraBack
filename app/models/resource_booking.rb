class ResourceBooking < ApplicationRecord
    belongs_to :resource_shift
    belongs_to :citizen
    has_many :notification, optional: true
    belongs_to :situation
    belongs_to :address

    validates_presence_of :address_id, 
                          :resource_shif_id,
                          :situation_id,
                          :citizen_id,
                          :active
                          :booking_reason,
                          :booking_start_time,
                          :booking_end_time


end
