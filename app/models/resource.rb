class Resource < ApplicationRecord
    belongs_to :service_place
    has_one :resource_type
    has_many :resource_shift

    validates_presence_of :resource_types_id, 
                          :service_place_id,
                          :minimum_schedule_time,
                          :maximum_schedule_timem
                          :active

end
