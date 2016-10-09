class AccountSerializer < ActiveModel::Serializer
  attributes :id, :uid, :provider
  #has_one :citizen
end
