class SolicitationSerializer < ActiveModel::Serializer
  attributes :id, :name, :cpf, :email, :cep, :phone, :sent
  has_one :city
end
