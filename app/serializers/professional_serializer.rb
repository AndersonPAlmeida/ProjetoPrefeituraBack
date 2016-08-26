class ProfessionalSerializer < ActiveModel::Serializer
  ActiveModelSerializers.config.default_includes = '**'
  attributes :id, :registration, :active
  has_one :account
  has_many :professionals_service_places
  has_many :service_places, :through => :professionals_service_places
end
