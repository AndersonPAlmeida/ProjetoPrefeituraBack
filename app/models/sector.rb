class Sector < ApplicationRecord

  # Associations #
  has_many   :blocks
  belongs_to :city_hall

  # @return all active sectors
  def self.all_active
    Sector.where(active: true)
  end
end
