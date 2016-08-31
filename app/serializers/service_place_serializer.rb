class ServicePlaceSerializer < ActiveModel::Serializer
  attributes :id, :active, :address_number, :address_street, :name, :neighborhood, :address_complement, :cep, :email, :phone1, :phone2, :url
end
