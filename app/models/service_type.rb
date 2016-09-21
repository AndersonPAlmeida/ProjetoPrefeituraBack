class ServiceType < ApplicationRecord
	belongs_to :sector

	def self.all_active
	  ServiceType.where(active: true)
	end
end
