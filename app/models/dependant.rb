class Dependant < ApplicationRecord

  # Associations #
  belongs_to :citizen
  has_many   :blocks

  # @return all active dependants
  def self.all_active
    Dependant.where(active: true)
  end
end
