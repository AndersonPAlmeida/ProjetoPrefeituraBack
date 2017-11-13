class ResourceType < ApplicationRecord
    belongs_to :resource
    belongs_to :city_hall


    validates_presence_of :resource_id,
                          :professional_responsible_id,
                          :execution_start_time.
                          :execution_end_time

end
