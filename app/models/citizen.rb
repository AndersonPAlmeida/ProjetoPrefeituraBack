class Citizen < ApplicationRecord
  belongs_to :account

  def self.keys
    return [:birth_date, :name, :rg, 
            :address_complement, 
            :address_number, 
            :address_street, :cep, 
            :cpf, :email, :neighborhood, 
            :note, :pcd, :phone1, :phone2, 
            :photo_content_type, 
            :photo_file_name, 
            :photo_file_size, 
            :photo_update_at]
  end
end
