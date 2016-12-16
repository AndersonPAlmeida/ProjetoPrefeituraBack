class ProfessionalsServicePlace < ApplicationRecord

  # Associations #
  belongs_to :service_place
  belongs_to :professional

  # Validations #
  validates_presence_of :active,
    :role
end
