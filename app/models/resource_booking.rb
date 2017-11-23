class ResourceBooking < ApplicationRecord
    belongs_to :resource_shift
    has_many :citizen
    has_many :notification
    has_one :situation
    has_one :service_place

    validates_presence_of :service_place_id, 
                          :resource_shift_id,
                          :situation_id,
                          :citizen_id,
                          :active,
                          :booking_reason,
                          :booking_start_time,
                          :booking_end_time


end
