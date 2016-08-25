class Professional < ApplicationRecord
  # Associations #
  has_and_belongs_to_many :service_places

  # @return list of professional's columns
  def self.keys
    return [ :active, :registration ]
  end

 # @return all active professionals
  def self.all_active
    Professional.where(active: true)
  end
end
