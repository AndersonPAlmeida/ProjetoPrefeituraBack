class Sector < ApplicationRecord
  has_many :blocks
  belongs_to :city_hall

  def self.all_active
    Sector.where(active: true)
  end

end
