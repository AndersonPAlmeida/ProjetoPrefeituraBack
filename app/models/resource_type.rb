class ResourceType < ApplicationRecord
    has_many :resource
    belongs_to :city_hall


    validates_presence_of :city_hall_id,
                          :name,
                          :mobile

end
