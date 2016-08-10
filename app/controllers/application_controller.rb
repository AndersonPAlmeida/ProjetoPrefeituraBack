class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  include ActionController::Serialization
  before_action :configure_permitted_parameters, if: :devise_controller?

protected

  # set sign_up hash to keys from citizen's registration form 
  # set sign_in hash to keys from citizen's login form
  # set account_update hash to keys required to update citizen's account
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up,
                                      keys: [ :password,
                                              :password_confirmation,
                                              :confirm_success_url,
                                              :confirm_error_urli,
                                              :birth_date, :name, :rg,
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
