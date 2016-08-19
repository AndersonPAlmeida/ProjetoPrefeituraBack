class AccountSerializer < ActiveModel::Serializer
  has_one :citizen
end
