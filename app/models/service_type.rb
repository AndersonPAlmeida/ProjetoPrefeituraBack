class ServiceType < ApplicationRecord

  # Associations #
  belongs_to :sector
  has_and_belongs_to_many :service_places

  # Validations #
  validates_presence_of :description
  validates_inclusion_of :active, in: [true, false]

  # @return all active service types
  def self.all_active
    ServiceType.where(active: true)
  end
end
