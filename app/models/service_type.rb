class ServiceType < ApplicationRecord
	belongs_to :sector
	has_and_belongs_to_many :service_places

	def self.all_active
	  ServiceType.where(active: true)
	end
end
