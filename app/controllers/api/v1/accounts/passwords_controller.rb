module Api::V1
  class Accounts::PasswordsController < DeviseTokenAuth::PasswordsController

    # this action is responsible for generating password reset tokens and
    # sending emails
    def create

      # give redirect value from params priority
      @redirect_url = params[:redirect_url]

      # fall back to default value if provided
      @redirect_url ||= DeviseTokenAuth.default_password_reset_url


      unless @redirect_url
        return render_create_error_missing_redirect_url
      end

      @resource = Account.find_by(uid: params[:cpf])
      if @resource.citizen.email.nil? or @resource.citizen.email.empty?
        render json: {
          errors: ["User #{params[:cpf]} does not have an email registered."]
        }, status: 422
        return
      end

      @resource.email = @resource.citizen.email
      @resource.save

      @email = @resource.email

      # if whitelist is set, validate redirect_url against whitelist
      if DeviseTokenAuth.redirect_whitelist
        unless DeviseTokenAuth::Url.whitelisted?(@redirect_url)
          return render_create_error_not_allowed_redirect_url
        end
      end

      if @resource
        yield @resource if block_given?
        @resource.send_reset_password_instructions({
          email: @email,
          provider: 'cpf',
          redirect_url: @redirect_url,
          client_config: params[:config_name]
        })

        if @resource.errors.empty?
          return render_create_success
        else
          render_create_error @resource.errors
        end
      else
        render_not_found_error
      end
    end

    def edit
      @resource = resource_class.reset_password_by_token({
        reset_password_token: resource_params[:reset_password_token]
      })

      if @resource && @resource.id
        client_id  = SecureRandom.urlsafe_base64(nil, false)
        token      = SecureRandom.urlsafe_base64(nil, false)
        token_hash = BCrypt::Password.create(token)
        expiry     = (Time.now + DeviseTokenAuth.token_lifespan).to_i

        @resource.tokens[client_id] = {
          token:  token_hash,
          expiry: expiry
        }

        # ensure that user is confirmed
        @resource.skip_confirmation! if @resource.devise_modules.include?(:confirmable) && !@resource.confirmed_at

        # allow user to change password once without current_password
        @resource.allow_password_change = true;

        @resource.save!
        yield @resource if block_given?

        url = gen_url(params[:redirect_url], {
          token:          token,
          client_id:      client_id,
          uid:            @resource.uid,
          expiry:         @resource.tokens[client_id]['expiry'],
          reset_password: true,
          config:         params[:config]
        })

        redirect_to(url)
      else
        url = gen_url(params[:redirect_url] + "/invalid")

        redirect_to(url)
      end
    end

    private

    def gen_url(url, params = {})
      uri = URI(url)
      res = "#{uri}"
      query = [uri.query, params.to_query].reject(&:blank?).join('&')
      res += "?#{query}"
      res += "##{uri.fragment}" if uri.fragment

      return res
    end

    def with_reset_password_token token
      recoverable = resource_class.with_reset_password_token(token)

      recoverable.reset_password_token = token if recoverable && recoverable.reset_password_token.present?
      recoverable
    end

    def render_edit_error
      render_error(404, "Token not found or expired!")
    end
  end
end
