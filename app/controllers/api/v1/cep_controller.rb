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
  class CepController < ApplicationController

    # POST /validate_cep
    def validate
      only_registered = true

      if not cep_params[:only_registered].nil?
        only_registered = cep_params[:only_registered]
      end

      result, status = Address.get_cep_response(
        cep_params[:number], only_registered)

      if status.nil?
        render json: result.to_json
      else
        render json: result, status: status
      end
    end

    private

    # Only allow a trusted parameter "white list" through.
    def cep_params
      params.require(:cep).permit(
        :number,
        :only_registered
      )
    end
  end
end
