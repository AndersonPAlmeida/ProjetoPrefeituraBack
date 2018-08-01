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
  class Accounts::SessionsController < DeviseTokenAuth::SessionsController

    # Overrides DeviseTokenAuth's SessionsController's in order to query
    # an account which citizen's cpf correspond to the cpf provided by
    # the sign_in form
    def create
      # Check which field should be used for authentication, in this case: cpf
      field = (resource_params.keys.map(&:to_sym) & resource_class.authentication_keys).first

      @resource = nil

      # get cpf and find correspondent account (@resource)
      if field
        q_value = resource_params[field]

        # finds account which citizens' cpf correspond to the request's
        @resource = resource_class.where(citizens: {cpf: q_value})
          .includes(:citizen)
          .where(provider: 'cpf').first  
      end

      # create token and sign in
      if @resource and valid_params?(field, q_value) and 
         (!@resource.respond_to?(:active_for_authentication?) or 
         @resource.active_for_authentication?)

        valid_password = @resource.valid_password?(resource_params[:password])

        if (@resource.respond_to?(:valid_for_authentication?) and 
           !@resource.valid_for_authentication? { valid_password }) or 
           !valid_password
          
          render_create_error_bad_credentials
          return
        end

        # create client id
        @client_id = SecureRandom.urlsafe_base64(nil, false)
        @token     = SecureRandom.urlsafe_base64(nil, false)

        @resource.tokens[@client_id] = {
          token: BCrypt::Password.create(@token),
          expiry: (Time.now + DeviseTokenAuth.token_lifespan).to_i
        }
        @resource.save

        sign_in(:account, @resource, store: false, bypass: false)

        yield @resource if block_given?

        render_create_success
      elsif @resource and 
        not (!@resource.respond_to?(:active_for_authentication?) or
        @resource.active_for_authentication?)

        render_create_error_not_confirmed
      else
        render_create_error_bad_credentials
      end
    end 
  end
end
