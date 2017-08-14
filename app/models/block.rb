class Block < ApplicationRecord

  # Associations #
  belongs_to :citizen
  belongs_to :sector
  belongs_to :dependant, optional: true
end
