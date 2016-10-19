class Professional < ApplicationRecord

  # Associations #
  belongs_to :account
  belongs_to :occupation
  has_one :citizen, through: :account
  has_many :professionals_service_places
  has_many :service_places, through: :professionals_service_places

  # Validations #
  validates_presence_of :occupation_id, :account_id

  # @return all active professionals
  def self.all_active
    Professional.where(active: true)
  end

  # @return [Array] list of roles
  def roles
    self.professionals_service_places.pluck(:role)
  end

  # @param role [String] role to be verified
  # @return [Boolean] professional has "role"
  def has_role? role
    self.roles.include?(role)
  end
end
