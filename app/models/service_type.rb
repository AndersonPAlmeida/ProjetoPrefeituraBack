class ServiceType < ApplicationRecord

  # Associations #
  belongs_to :sector
  has_and_belongs_to_many :service_places

  # @return all active service types
  def self.all_active
    ServiceType.where(active: true)
  end
end
