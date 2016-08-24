class AccountSerializer < ActiveModel::Serializer
  attributes :id, :uid, :provider
  belongs_to :citizen
end
