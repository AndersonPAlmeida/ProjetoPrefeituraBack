class SolicitationSerializer < ActiveModel::Serializer
  attributes :id, 
             :cep, 
             :cpf, 
             :email, 
             :name, 
             :phone, 
             :sent

  has_one :city
end
