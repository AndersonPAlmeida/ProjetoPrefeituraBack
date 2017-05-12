class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  include ActionController::Serialization
  include ActionController::RequestForgeryProtection
  include Pundit

  rescue_from Pundit::NotAuthorizedError, 
    with: :user_not_authorized

  before_action :configure_permitted_parameters,
    if: :devise_controller?
  protect_from_forgery with: :null_session, 
    if: Proc.new { |c| c.request.format.json? }

  def current_user
    if not @resource.nil?
      @resource.citizen
    end
  end

  protected

  # permit parameters for devise functions
  def configure_permitted_parameters
    citizen_keys = Citizen.keys

    # set sign_up hash to keys from citizen's registration form
    devise_parameter_sanitizer.permit(
      :sign_up, keys: [
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
        :rg,
				:password,
        :password_confirmation
      ]

      #citizen_keys + [
      #  :password, 
      #  :password_confirmation
      #]
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

  private

  def user_not_authorized(exception)
    render json: {
      errors: ["User not authorized"]
    }, status: 500
  end
end
