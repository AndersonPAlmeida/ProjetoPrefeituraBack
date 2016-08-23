class CityHallSerializer < ActiveModel::Serializer
  attributes :id, :city_id, :active, :address_number, 
             :address_street, :block_text, :cep, 
             :citizen_access, :citizen_register, 
             :name, :neighborhood, :previous_notice, 
             :schedule_period, :address_complement, 
             :description, :email, :logo_content_type, 
             :logo_file_name, :logo_file_size, 
             :logo_updated_at, :phone1, :phone2, 
             :support_email, :show_professional, :url
end
