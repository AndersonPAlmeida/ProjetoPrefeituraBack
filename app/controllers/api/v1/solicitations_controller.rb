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
  class SolicitationsController < ApplicationController

    before_action :set_solicitation, only: [:show, :update, :destroy]

    # Had to be specified instead of "include Authenticable" because of the create
    # method exception
    before_action :authenticate_v1_account!, :verify_permission, except: [:create]


    # GET /solicitations
    def index
      @solicitations = policy_scope(Solicitation.filter(params[:q], params[:page],
        Professional.get_permission(current_user[1])))


      if @solicitations.nil?
        render json: {
          # errors: ["You don't have the permission to view solicitations."]
          errors: ["Você não tem permissão para listar solicitações!"]
        }, status: 403
        return
      else
        response = Hash.new
        response[:num_entries] = @solicitations.total_count
        response[:entries] = @solicitations.index_response

        render json: response.to_json
        return
      end
    end


    # GET /solicitations/1
    def show
      if @solicitation.nil?
        render json: {
          # errors: ["Solicitation #{params[:id]} does not exist."]
          errors: ["Solicitação #{params[:id]} não existe!"]
        }, status: 404
      else
        begin
          authorize @solicitation, :show?
        rescue
          render json: {
            # errors: ["You are not allowed to view solicitations"]
            errors: ["Você não tem permissão para listar visualizar solicitações!"]
          }, status: 403
          return
        end

        render json: @solicitation.complete_info_response
      end
    end


    # POST /solicitations
    def create
      @solicitation = Solicitation.new(solicitation_params)

      if @solicitation.save
        render json: @solicitation.complete_info_response, status: :created
      else
        render json: @solicitation.errors, status: :unprocessable_entity
      end
    end


    private

    # Use callbacks to share common setup or constraints between actions.
    def set_solicitation
      begin
        @solicitation = Solicitation.find(params[:id])
      rescue
        @solicitation = nil
      end
    end


    # Only allow a trusted parameter "white list" through.
    def solicitation_params
      params.require(:solicitation).permit(
        :cep,
        :cpf,
        :email,
        :name,
        :phone,
      )
    end
  end
end
