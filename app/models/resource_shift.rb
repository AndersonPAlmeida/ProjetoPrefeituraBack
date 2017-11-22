class ResourceShift < ApplicationRecord
    has_many :resource_booking
    has_one :professionals_service_place
    has_one :resource
    has_many :resource_shift

    validates_presence_of :resource_id,
                          :professional_responsible_id,
                          :execution_start_time,
                          :execution_end_time,
                          :borrowed,
                          :active

end
