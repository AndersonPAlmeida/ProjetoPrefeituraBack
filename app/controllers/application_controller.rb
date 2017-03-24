class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  include ActionController::Serialization
  include ActionController::RequestForgeryProtection
  include Pundit

  protect_from_forgery
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  # permit parameters for devise functions
  def configure_permitted_parameters
    citizen_keys = Citizen.keys

    # set sign_up hash to keys from citizen's registration form
    devise_parameter_sanitizer.permit(
      :sign_up, keys: 
      citizen_keys + [
        :password, 
        :password_confirmation
      ]
    )

    # set sign_in hash to keys from citizen's login form
    devise_parameter_sanitizer.permit(
      :sign_in, keys: [
        :cpf,
        :password
      ]
    )

    # set account_update hash to keys required to update citizen's account
    devise_parameter_sanitizer.permit(
      :account_update, keys: [
        citizen: citizen_keys
      ]
    )
  end
end
