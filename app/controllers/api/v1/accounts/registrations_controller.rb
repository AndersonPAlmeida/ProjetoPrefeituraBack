module Api::V1 
  class Accounts::RegistrationsController < DeviseTokenAuth::RegistrationsController
    def create
      @keys = sign_up_params
      Rails.logger.info "#{@keys.inspect}"
      keyset = Citizen.keys
#      @account_keys = Hash.new
      ActionController::Parameters.permit_all_parameters = true
      @account_keys = ActionController::Parameters.new

      keyset.each do |i|
        if @keys[i] != nil
          @account_keys[i] = @keys.delete(i) 
        end
      end

      #@account_keys = @keys.slice!(*keyset)
      Rails.logger.info "=============" 
      Rails.logger.info "#{@keys.inspect}"
      Rails.logger.info "#{@account_keys.inspect}"
      Rails.logger.info "=============" 

      @resource = resource_class.new(@keys)
      @citizen = Citizen.new(@account_keys)
      @resource.provider = "cpf"

      # honor devise configuration for case_insensitive_keys
      #if resource_class.case_insensitive_keys.include?(:email)
      #  @resource.email = sign_up_params[:email].try :downcase
      #else
      #  @resource.email = sign_up_params[:email]
      #end

      # @resource.cpf = sign_up_params[:cpf]
      # @resource.uid = @resource.cpf
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
#        resource_class.set_callback("create", :after, :send_on_create_confirmation_instructions)
#        resource_class.skip_callback("create", :after, :send_on_create_confirmation_instructions)
        if @resource.save
          yield @resource if block_given?

#          unless @resource.confirmed?
#            # user will require email authentication
#            @resource.send_confirmation_instructions({
#              client_config: params[:config_name],
#              redirect_url: @redirect_url
#            })

 #         else
            # email auth has been bypassed, authenticate user
            @client_id = SecureRandom.urlsafe_base64(nil, false)
            @token     = SecureRandom.urlsafe_base64(nil, false)

            @resource.tokens[@client_id] = {
              token: BCrypt::Password.create(@token),
              expiry: (Time.now + DeviseTokenAuth.token_lifespan).to_i
            }

            @resource.save!

            update_auth_header
#          end
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

    def sign_up_params
      params.permit(*params_for_resource(:sign_up))
    end
  end
end
