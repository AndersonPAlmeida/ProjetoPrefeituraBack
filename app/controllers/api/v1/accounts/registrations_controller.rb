# This file is part of Agendador.
#
# Agendador is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Agendador is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Agendador.  If not, see <https://www.gnu.org/licenses/>.

module Api::V1 
  class Accounts::RegistrationsController < DeviseTokenAuth::RegistrationsController
    require "#{Rails.root}/lib/image_parser.rb"

    # Overrides DeviseTokenAuth's RegistrationsController's create method.
    # It's necessary due to the fact that a citizen and an account have to
    # be created on registration with the proper params, while the default
    # devise_token_auth creates only a user with email
    def create
      # permit all parameters for creating citizen_params
      ActionController::Parameters.permit_all_parameters = true

      # distribute params between account and citizen
      citizen_params = ActionController::Parameters.new
      account_params = sign_up_params
      citizen_keys = Citizen.keys

      citizen_keys.each do |i|
        citizen_params[i] = account_params.delete(i)
      end

      # create new account and set provider to cpf
      @resource = resource_class.new(account_params)
      @resource.provider = "cpf"

      # create new citizen
      if citizen_params[:cep]
        citizen_params[:city_id] = Address.get_city_id(citizen_params[:cep])
      end

      @citizen = Citizen.new(citizen_params)

      # honor devise configuration for case_insensitive_keys
      @citizen.email = citizen_params[:email].try :downcase
      @resource.email = @citizen.email
      
      if params[:image]
        begin
          params[:image] = Agendador::Image::Parser.parse(params[:image])
          #@citizen.update_attribute(:avatar, params[:image])
          @citizen.avatar = params[:image]
        ensure
          Agendador::Image::Parser.clean_tempfile
        end
      end

      # set uid to corresponding citizen's cpf
      if !@citizen.cpf.nil?
        @resource.uid = @citizen.cpf.gsub(/[^0-9]/, '')
      end

      begin
        # override email confirmation, must be sent manually from ctrl
        resource_class.set_callback("create", :after, 
                                    :send_on_create_confirmation_instructions)
        resource_class.skip_callback("create", :after, 
                                     :send_on_create_confirmation_instructions)

        if @resource.save
          yield @resource if block_given?

          unless @resource.confirmed?
            # user will require email authentication
            @resource.send_confirmation_instructions({
              client_config: params[:config_name],
              redirect_url: @redirect_url
            })

          else
            @citizen.account_id = @resource.id
            @citizen.active = true

            if @citizen.save
              @citizen.save!
            else
              Account.delete(@citizen.account_id)
              return render_create_citizen_error
            end

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

    # Overrides DeviseTokenAuth's RegistrationsController's update method.
    # It's necessary due to the fact that a citizen and an account have to
    # be updated on registration with the proper params, while the default
    # devise_token_auth can update only the account information
    def update
      if not @resource
        render_update_error_user_not_found
        return
      end

      # Update account with params except citizen's
      if @resource.send(resource_update_method, account_update_params.except(:citizen, :professional))
        yield @resource if block_given?

        # Check if citizen's params are not empty
        if account_update_params[:citizen].nil?
          render_update_success
          return
        end

        # Update citizen with account_update_params[:citizen]
        if @resource.citizen.update(account_update_params[:citizen])

          # Update professional info if provided
          if not account_update_params[:professional].nil?
            if not @resource.citizen.professional.nil? and 
              (not @resource.citizen.professional.update(account_update_params[:professional]))

              render json: @resource.citizen.professional.errors, status: :unprocessable_entity
              return
            else
              @resource.citizen.professional.save!
            end
          end

          # Update image if provided
          if params[:citizen][:image]
            if params[:citizen][:image][:content_type] == "delete"
              @resource.citizen.avatar.destroy
              @resource.citizen.save
            else
              begin
                params[:citizen][:image] = Agendador::Image::Parser.parse(params[:citizen][:image])
                @resource.citizen.update_attribute(:avatar, params[:citizen][:image])
              ensure
                Agendador::Image::Parser.clean_tempfile
              end
            end
          end

          # The city id has to be updated in case the cep needs change
          if not account_update_params[:citizen][:cep].nil?
            city_id = Address.get_city_id(account_update_params[:citizen][:cep])

            if @resource.citizen.update_attribute(:city_id, city_id)
              render_update_success
            end
          else
            render_update_success
          end

        else
          render json: @resource.citizen.errors, status: :unprocessable_entity
        end 

      else
        render_update_error
      end
    end

    protected

    # Overrides DeviseTokenAuth's RegistrationsController's
    # render_create_success method in order to render account
    # informations with token_validation_response method
    def render_create_success
      #render json: @resource
      render json: {
        data:   @resource.token_validation_response
      }, status: 201
    end

    # Overrides DeviseTokenAuth's RegistrationsController's
    # render_update_success method in order to render account
    # informations with token_validation_response method
    def render_update_success
      #render json: @resource
      render json: {
        data:   @resource.token_validation_response
      }, status: 200
    end

    # Overrides DeviseTokenAuth's RegistrationsController's 
    # render_create_error_email_already_exists method in order
    # to adapt to @citizen.cpf already exists
    def render_create_error_email_already_exists
      render json: {
        status: 'error',
        data:   @citizen,
        errors: [I18n.t("devise_token_auth.registrations.email_already_exists",
                        email: @citizen.cpf)]
      }, status: 422
    end

    # Overrides DeviseTokenAuth's RegistrationsController's 
    # render_create_citizen_error method in order to adapt
    # method to show @citizen.cpf
    def render_create_citizen_error
      render json: {
        errors: @citizen.errors.to_hash.merge(full_messages: @citizen.errors.full_messages)
      }, status: 422
    end

    # Overrides DeviseTokenAuth's RegistrationsController's 
    # render_update_error method in order to display
    # only the necessary information
    def render_update_error
      render json: {
        errors: resource_errors[:full_messages]
      }, status: 422
    end

    # Overrides DeviseTokenAuth's RegistrationsController's 
    # render_update_error_user_not_found method in order to display
    # only the necessary information
    def render_update_error_user_not_found
      render json: {
        errors: [I18n.t("devise_token_auth.registrations.user_not_found")]
      }, status: 404
    end
  end
end
