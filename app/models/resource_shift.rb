class ResourceShift < ApplicationRecord
    has_many :resource_booking
    belongs_to :professionals_service_place
    belongs_to :resource
    belongs_to :resource_shift
    has_many :resource_shift

    validates_presence_of :resource_id,
                          :professional_responsible_id,
                          :execution_start_time,
                          :execution_end_time,
                          :borrowed,
                          :active

end
