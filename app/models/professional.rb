class Professional < ApplicationRecord

  # Associations #
  belongs_to :account
  has_one :citizen, through: :account
  has_many :professionals_service_places
  has_many :service_places, :through => :professionals_service_places

  # @return list of professional's columns
  def self.keys
    return [ :active, :registration ]
  end

 # @return all active professionals
  def self.all_active
    Professional.where(active: true)
  end
end
