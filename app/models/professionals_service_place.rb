class ProfessionalsServicePlace < ApplicationRecord
  # Associations #
  belongs_to :service_place
  belongs_to :professional
end
