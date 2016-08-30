class Professional < ApplicationRecord
  # Associations #
  belongs_to :account
  has_one :citizen, through: :account

  # @return list of professional's columns
  def self.keys
    return [ :active, :registration ]
  end

 # @return all active professionals
  def self.all_active
    Professional.where(active: true)
  end
end
