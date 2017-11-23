class ProfessionalsServicePlace < ApplicationRecord

  # Associations #
  belongs_to :service_place
  belongs_to :professional
  belongs_to :resource_shift

  # Validations #
  validates_presence_of :active, :role

  def info_listing
    return {
      id: self.service_place.id, 
      name: self.service_place.name, 
      role: self.role
    }
  end
end
