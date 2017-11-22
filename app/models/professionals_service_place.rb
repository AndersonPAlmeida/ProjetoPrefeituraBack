class ProfessionalsServicePlace < ApplicationRecord

  # Associations #
  belongs_to :service_place
  belongs_to :professional

  # Validations #
  validates_presence_of :active, :role
  validates :service_place, exclusion: { in: [nil] }

  def info_listing
    return {
      id: self.service_place.id, 
      name: self.service_place.name, 
      role: self.role
    }
  end
end
