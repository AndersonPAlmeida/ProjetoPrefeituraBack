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

  # This method is useful in the rest of the application for checking permissions
  #
  # @return [Citizen, String] the current logged citizen and the permission 
  # he wants to use for his request
  def current_user
    if not @resource.nil?
      return @resource.citizen, params[:permission]
    end
  end

  # It is executed in every request that requires authorization (called in 
  # authenticable concern as a before_action). It checks if the current_user
  # has the permission he claims in the parameters, an errors gets returned if
  # he doesn't
  def verify_permission
    if not current_user.nil? and not params[:permission].nil?

      professional = current_user[0].professional

      # The given permission might be a positive integer, in that case, it
      # represents the id of the join table "ProfessionalsServicePlace", which
      # contains the desired permission (role) name.
      if /\A\d+\z/.match(params[:permission])
        begin
          psp = ProfessionalsServicePlace.find(params[:permission])

          if not professional.nil? and (psp.professional.id != professional.id)
            render json: {
              errors: ["You don't have a permission_id: #{params[:permission]}."]
            }, status: 401
            return
          end

          params[:permission] = psp.role
        rescue

          # If the given id doesn't exist, than it must be treated as if it was
          # never provided.
          params[:permission] = nil
          return
        end
      end

      permission = params[:permission]

      # Check if the given permission exists
      if not ["citizen", "responsavel_atendimento", "atendente_local", 
              "adm_local", "adm_prefeitura", "adm_c3sl"].include? permission

        render json: {
          errors: ["The permission #{permission} does not exist."]
        }, status: 404

        # Check if the current_user possesses the given permission
      elsif (professional.nil? and permission != 'citizen') or 
        (not professional.nil? and not professional.roles.include? permission and
         permission != "citizen" )

        render json: {
          errors: ["You don't have the #{permission} permission."]
        }, status: 401

      end
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
