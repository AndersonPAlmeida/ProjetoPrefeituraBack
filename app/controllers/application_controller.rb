class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  include ActionController::Serialization
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up_account, 
                                      keys: [ :password, 
                                              :password_confirmation, 
                                              :confirm_success_url, 
                                              :confirm_error_url ])

    devise_parameter_sanitizer.permit(:sign_up_citizen, 
                                      keys: [ :birth_date, :name, :rg, 
                                              :address_complement, 
                                              :address_number, 
                                              :address_street, :cep, 
                                              :cpf, :email, :neighborhood, 
                                              :note, :pcd, :phone1, :phone2, 
                                              :photo_content_type, 
                                              :photo_file_name, 
                                              :photo_file_size, 
                                              :photo_update_at ])

    devise_parameter_sanitizer.permit(:sign_in, keys: [ :cpf, :password ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :cpf ])
  end
end
