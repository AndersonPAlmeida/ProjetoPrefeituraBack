class ServiceTypesServicePlace < ApplicationRecord

  # Associations #
  belongs_to :service_place
  belongs_to :service_type

  # Validations #
  validates_presence_of :active
end
