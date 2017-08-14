class ServicePlaceSerializer < ActiveModel::Serializer
  attributes :id, 
    :active, 
    :address_complement, 
    :address_number, 
    :address_street, 
    :cep, 
    :email, 
    :name, 
    :neighborhood, 
    :phone1, 
    :phone2, 
    :url
end
