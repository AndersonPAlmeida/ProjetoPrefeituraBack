class ProfessionalSerializer < ActiveModel::Serializer
  ActiveModelSerializers.config.default_includes = '**'
  attributes :id, :registration, :active
  has_one :citizen, through: :account
end
