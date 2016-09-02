class DependantSerializer < ActiveModel::Serializer
  attributes :id, :active, :deactivated
  has_one :citizen
end
