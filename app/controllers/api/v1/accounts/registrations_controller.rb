module Api::V1 
  class Accounts::RegistrationsController < DeviseTokenAuth::RegistrationsController
    def create
      # permit all parameters for creating @citizen_params
      ActionController::Parameters.permit_all_parameters = true

      # distribute params between account and citizen
      @citizen_params = ActionController::Parameters.new
      @account_params = sign_up_params
      citizen_keys = Citizen.keys
      citizen_keys.each do |i|
        if @account_params[i] != nil
          @citizen_params[i] = @account_params.delete(i)
        end
      end

      # create new account and set provider to cpf
      @resource = resource_class.new(@account_params)
      @resource.provider = "cpf"

      # create net citizen
      @citizen = Citizen.new(@citizen_params)

      # honor devise configuration for case_insensitive_keys
      #if @resouce.case_insensitive_keys.include?(:email)
      #  @citizen.email = @citizen_params[:email].try :downcase
      #else
      #  @citizen.email = @citizen_params[:email]
      #end

      # set uid to corresponding citizen's cpf
      @resource.uid = @citizen.cpf

      # give redirect value from params priority
      @redirect_url = params[:confirm_success_url]

      # fall back to default value if provided
      @redirect_url ||= DeviseTokenAuth.default_confirm_success_url

      # success redirect url is required
      if resource_class.devise_modules.include?(:confirmable) && !@redirect_url
        return render_create_error_missing_confirm_success_url
      end

      # if whitelist is set, validate redirect_url against whitelist
      if DeviseTokenAuth.redirect_whitelist
        unless DeviseTokenAuth.redirect_whitelist.include?(@redirect_url)
          return render_create_error_redirect_url_not_allowed
        end
      end

      begin
        # override email confirmation, must be sent manually from ctrl
        resource_class.set_callback("create", :after, :send_on_create_confirmation_instructions)
        resource_class.skip_callback("create", :after, :send_on_create_confirmation_instructions)
        if @resource.save
          yield @resource if block_given?

          unless @resource.confirmed?
            # user will require email authentication
            @resource.send_confirmation_instructions({
              client_config: params[:config_name],
              redirect_url: @redirect_url
            })

          else
            # email auth has been bypassed, authenticate user
            @client_id = SecureRandom.urlsafe_base64(nil, false)
            @token     = SecureRandom.urlsafe_base64(nil, false)

            @resource.tokens[@client_id] = {
              token: BCrypt::Password.create(@token),
              expiry: (Time.now + DeviseTokenAuth.token_lifespan).to_i
            }

            @resource.save!

            update_auth_header
          end
          render_create_success
        else
          clean_up_passwords @resource
          render_create_error
        end
      rescue ActiveRecord::RecordNotUnique
        clean_up_passwords @resource
        render_create_error_email_already_exists
      end
    end
  end
end
