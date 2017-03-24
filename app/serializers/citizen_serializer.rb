class CitizenSerializer < ActiveModel::Serializer
  attributes :id, 
    :active,
    :address_complement, 
    :address_number, 
    :address_street, 
    :birth_date, 
    :cep, 
    :city_id, 
    :cpf, 
    :email, 
    :name, 
    :neighborhood, 
    :note, 
    :pcd, 
    :phone1, 
    :phone2, 
    :rg 

  belongs_to :account
end
