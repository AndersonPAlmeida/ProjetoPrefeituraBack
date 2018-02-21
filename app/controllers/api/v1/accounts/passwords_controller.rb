module Api::V1 
	class Accounts::PasswordsController < DeviseTokenAuth::PasswordsController

		# this action is responsible for generating password reset tokens and
		# sending emails
		def create
			unless resource_params[:email]
				return render_create_error_missing_email
			end

			# give redirect value from params priority
			@redirect_url = params[:redirect_url]

			# fall back to default value if provided
			@redirect_url ||= DeviseTokenAuth.default_password_reset_url

			unless @redirect_url
				return render_create_error_missing_redirect_url
			end

			# if whitelist is set, validate redirect_url against whitelist
			if DeviseTokenAuth.redirect_whitelist
				unless DeviseTokenAuth::Url.whitelisted?(@redirect_url)
					return render_create_error_not_allowed_redirect_url
				end
			end

			@resource = Account.find_by(uid: params[:cpf]) 
			@email = @resource.email 

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

				redirect_to(@resource.build_auth_url(params[:redirect_url], {
					token:          token,
					client_id:      client_id,
					reset_password: true,
					config:         params[:config]
				}))
			else
				render_edit_error
			end
		end

		private

		def with_reset_password_token token
			recoverable = resource_class.with_reset_password_token(token)

			recoverable.reset_password_token = token if recoverable && recoverable.reset_password_token.present?
			recoverable
		end
	end
end
